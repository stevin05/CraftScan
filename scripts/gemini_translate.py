import os
import sys
import json
import io
import requests
import time
import datetime
from itertools import batched
from collections import deque
from google import genai
from google.genai import errors

# --- Helpers ---


def chunk_dict(data, size):
    """Yields small dictionaries of 'size' using itertools.batched."""
    for batch in batched(data.items(), size):
        yield dict(batch)


def filter_context_content(raw_content, limit=100):
    """Filters large context files to reduce token usage (100 keys per letter)."""
    if not raw_content:
        return b""

    text = (
        raw_content.decode("utf-8") if isinstance(raw_content, bytes) else raw_content
    )
    output_lines = []
    letter_counts = {}

    for line in text.splitlines():
        stripped = line.strip()
        # Keep comments and headers
        if not stripped or stripped.startswith("--"):
            output_lines.append(line)
            continue

        # Simple parser for KEY = "VAL"
        if "=" in stripped:
            potential_key = stripped.split("=")[0].strip()
            if potential_key and potential_key[0].isalpha():
                first_char = potential_key[0].upper()
                count = letter_counts.get(first_char, 0)
                if count < limit:
                    output_lines.append(line)
                    letter_counts[first_char] = count + 1
                continue  # Skip if over limit
        output_lines.append(line)

    return "\n".join(output_lines).encode("utf-8")


def dump_translations(target_locale, model_used, translations):
    """Appends translations to the locale file."""
    target_file_path = f"Locales/{target_locale}.lua"
    current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    sorted_keys = sorted(translations.keys())

    with open(target_file_path, "a", encoding="utf-8") as lua_file:
        lua_file.write(f"\n-- AI Generated: {current_time} using {model_used}\n")
        for key in sorted_keys:
            value = translations[key]
            clean_val = value.replace('"', '\\"').replace("\n", "\\n")

            if key.startswith("LID."):
                lua_file.write(f'L[{key}] = "{clean_val}"\n')
            else:
                lua_file.write(f'L["{key}"] = "{clean_val}"\n')

    print(f"Successfully updated {target_file_path}")


def fetch_gs(lang):
    """Fetches and filters GlobalStrings from GitHub."""
    url = f"https://raw.githubusercontent.com/tekkub/wow-globalstrings/refs/heads/master/GlobalStrings/{lang}.lua"
    print(f"Fetching {lang} reference...")
    r = requests.get(url)
    return filter_context_content(r.content) if r.status_code == 200 else None


def upload_to_gemini(client, content, display_name):
    """Uploads bytes content to Gemini File API."""
    if not content:
        return None
    file_stream = io.BytesIO(content)
    return client.files.upload(
        file=file_stream,
        config={"display_name": display_name, "mime_type": "text/plain"},
    )


# --- Main Logic ---


def main():
    if len(sys.argv) < 2:
        print("Usage: python gemini_translate.py <locale1,locale2,...>")
        sys.exit(1)

    # 1. Parse Locales
    input_arg = sys.argv[1]
    target_locales = [l.strip() for l in input_arg.split(",")]

    # 2. Setup Gemini
    client = genai.Client(api_key=os.environ.get("GEMINI_API_KEY"))

    # 3. Model Management
    available_models = [
        m.name
        for m in client.models.list()
        if "flash" in m.name and "tts" not in m.name and "image" not in m.name
    ]

    if not available_models:
        print("Error: No compatible Gemini Flash models found.")
        sys.exit(1)

    # 4. Global Context (enUS) - Upload Once
    en_gs_content = fetch_gs("enUS")
    en_file = upload_to_gemini(client, en_gs_content, "GlobalStrings_enUS")

    # --- Process Each Language ---
    for locale in target_locales:
        print(f"\n--------------------------------------------------")
        print(f"🚀 Starting translation for: {locale}")
        print(f"--------------------------------------------------")

        json_path = f"missing_keys_{locale}.json"
        if not os.path.exists(json_path):
            print(f"⚠️ {json_path} not found. Skipping.")
            continue

        with open(json_path, "r", encoding="utf-8") as f:
            raw_keys = json.load(f)

        if not raw_keys or len(raw_keys) == 0:
            print(f"✅ No missing keys for {locale}. Skipping.")
            continue

        # Sort the keys alphabetically
        missing_keys = dict(sorted(raw_keys.items()))
        print(f"Loaded {len(missing_keys)} keys for {locale}.")

        # Upload Target Context
        target_gs_content = fetch_gs(locale)
        target_file = upload_to_gemini(
            client, target_gs_content, f"GlobalStrings_{locale}"
        )

        # Current file list for this locale
        current_files = [f for f in [en_file, target_file] if f]

        # Initialize Loop State
        chunks = deque(chunk_dict(missing_keys, 50))
        processed = 0

        # Model State
        model_index = 0
        model = available_models[model_index]
        last_succeeded = None

        while chunks:
            total_chunks = processed + len(chunks)
            processed += 1
            batch = chunks.popleft()

            print(
                f"[{locale}] Processing chunk {processed}/{total_chunks} using {model}..."
            )

            prompt_base = f"""
            You are an expert World of Warcraft localizer. 
            Translate the attached JSON keys into {locale}.
            GUIDELINES:
            - Use the attached GlobalStrings files to find official Blizzard terms.
            - Maintain WoW fantasy tone.
            - Return ONLY valid JSON with the exact same keys as input.
            """

            while True:
                try:
                    full_prompt = f"{prompt_base}\n{json.dumps(batch, indent=2)}"
                    response = client.models.generate_content(
                        model=model, contents=current_files + [full_prompt]
                    )

                    raw_text = (
                        response.text.strip().replace("```json", "").replace("```", "")
                    )
                    translations = json.loads(raw_text)

                    original_keys = set(batch.keys())
                    received_keys = set(translations.keys())

                    hallucinated = received_keys - original_keys
                    if hallucinated:
                        print(f"  ⚠️ Removing {len(hallucinated)} hallucinated keys")
                        for k in hallucinated:
                            del translations[k]

                    missed = original_keys - received_keys
                    if missed:
                        missed_data = {k: batch[k] for k in missed}
                        if chunks:
                            chunks[0].update(missed_data)
                            chunks[0] = dict(sorted(chunks[0].items()))  # Keep sorted
                            print(f"  ♻️ Re-queued {len(missed)} keys to next batch")
                        else:
                            chunks.append(missed_data)
                            print(
                                f"  ♻️ Re-queued {len(missed)} keys to new final batch"
                            )

                    dump_translations(locale, model, translations)
                    last_succeeded = model

                    # Try to stay under the rate limits
                    time.sleep(10)
                    break

                except Exception as e:
                    if (
                        last_succeeded == model
                        and isinstance(e, errors.ClientError)
                        and e.code == 429
                    ):
                        print(f"  ⏳ Rate limit on working model. Sleeping 65s...")
                        last_succeeded = None
                        time.sleep(65)
                        continue

                    print(f"  ❌ Error: {e}")
                    if model_index < len(available_models) - 1:
                        model_index += 1
                        model = available_models[model_index]
                        print(f"  🔄 Swapping to model: {model}")
                    else:
                        print("  🛑 All models exhausted. Stopping this language.")
                        sys.exit(1)  # Fail the job so we know it stopped

        # Cleanup Target File
        if target_file:
            client.files.delete(name=target_file.name)

    # Final Cleanup
    if en_file:
        client.files.delete(name=en_file.name)


if __name__ == "__main__":
    main()
