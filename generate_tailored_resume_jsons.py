
import json
import os

FIELDS_TO_PROCESS = {
    'work': {
        'summary': 'summary',
        'highlights': 'highlights'
    },
    'skills': {
        'keywords': 'keywords'
    }
}

def load_json(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        return json.load(file)


def save_json(data, file_path):
    with open(file_path, 'w', encoding='utf-8') as file:

        json.dump(data, file, ensure_ascii=False, indent=4)


def process_field(value, resume_key):
    if isinstance(value, dict):
        return value.get(resume_key, value.get('default', ''))
    elif isinstance(value, list):
        processed_list = [process_field(item, resume_key) for item in value]
        return [item for item in processed_list if item]
    else:
        return value


def process_fields(data, fields_to_process, resume_key):
    if isinstance(data, list):
        return [process_fields(item, fields_to_process, resume_key) for item in data]

    if isinstance(data, dict):
        new_dict = {}
        for k, v in data.items():
            if k in fields_to_process:
                if isinstance(fields_to_process[k], dict):
                    new_dict[k] = process_fields(v, fields_to_process[k], resume_key)
                else:
                    new_dict[k] = process_field(v, resume_key)
            else:
                new_dict[k] = v
        return new_dict
    return data

def generate_resume(base_resume, resume_key):
    new_resume = base_resume.copy()

    for key, fields in FIELDS_TO_PROCESS.items():
        if key in base_resume:
            new_resume[key] = process_fields(base_resume[key], fields, resume_key)

    return new_resume


def main():
    base_resume_path = 'base-resume.json'
    output_dir = 'generated_resume_jsons'
    resume_keys = ['Main', 'Data', 'Django', 'Python', 'Pharmacy', ]

    base_resume = load_json(base_resume_path)

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for key in resume_keys:
        new_resume = generate_resume(base_resume, key)
        output_path = os.path.join(output_dir, f'{key}.json')
        save_json(new_resume, output_path)


if __name__ == "__main__":
    main()