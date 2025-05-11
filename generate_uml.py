import os
import re
from pathlib import Path

def parse_classes(filepath):
    content = Path(filepath).read_text()

    class_pattern = re.compile(r'class\s+(\w+)(?:\s+extends\s+\w+)?\s*{', re.MULTILINE)
    static_method_pattern = re.compile(r'static\s+([^\s]+)\s+(\w+)\s*\([^\)]*\)\s*{', re.MULTILINE)
    method_pattern = re.compile(r'(?:Widget|State<.*?>|Color|void|int|List<.*?>|TimeOfDay|Future<.*?>|[A-Z][a-zA-Z0-9_<>?]*)\s+(\w+)\s*\([^\)]*\)\s*{', re.MULTILINE)
    field_pattern = re.compile(r'(?:final\s+)?(int|List<.*?>|TimeOfDay|Color)\s+(\w+);', re.MULTILINE)

    classes = []
    class_blocks = [(m.start(), m.group(1)) for m in class_pattern.finditer(content)]

    for i, (start_idx, class_name) in enumerate(class_blocks):
        end_idx = class_blocks[i + 1][0] if i + 1 < len(class_blocks) else len(content)
        class_body = content[start_idx:end_idx]

        fields = field_pattern.findall(class_body)
        static_methods = static_method_pattern.findall(class_body)
        methods = method_pattern.findall(class_body)

        members = []

        for field_type, field_name in fields:
            members.append(f'{field_type} {field_name}')

        for return_type, method_name in static_methods:
            members.append(f'{{static}} +{return_type} {method_name}()')

        # Avoid duplicates from static
        for method_name in methods:
            if not any(method_name in m for m in members):
                members.append(f'{method_name}()')

        classes.append({
            'name': class_name,
            'members': members
        })

    return classes

def get_namespace_from_path(filepath, base_dir):
    rel_path = os.path.relpath(filepath, base_dir)
    parts = ['iitropar'] + rel_path.replace(".dart", "").split(os.sep)
    return "::".join(parts)

def generate_puml(namespace, classes):
    lines = ['@startuml', 'set namespaceSeparator ::', '']
    for cls in classes:
        lines.append(f'class "{namespace}::{cls["name"]}" {{')
        for m in cls["members"]:
            lines.append(f'  {m}')
        lines.append('}\n')
    lines.append('@enduml')
    return '\n'.join(lines)

def main(lib_dir, output_dir):
    os.makedirs(output_dir, exist_ok=True)

    for root, _, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                full_path = os.path.join(root, file)
                classes = parse_classes(full_path)
                if not classes:
                    continue
                namespace = get_namespace_from_path(full_path, lib_dir)
                puml_content = generate_puml(namespace, classes)
                out_file = namespace.replace("::", "_") + ".puml"
                out_path = os.path.join(output_dir, out_file)
                Path(out_path).write_text(puml_content)
                print(f"✅ Generated: {out_path}")

if __name__ == "__main__":
    main("lib", "puml_outputs")
