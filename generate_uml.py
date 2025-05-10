import os
import re
from pathlib import Path

NAMESPACE_SEPARATOR = "::"

def parse_dart_file(filepath: Path, lib_root: Path):
    with open(filepath, 'r', encoding='utf-8') as file:
        content = file.read()

    relative_path = filepath.relative_to(lib_root).with_suffix('')
    namespace = NAMESPACE_SEPARATOR.join(relative_path.parts[:-1])  # exclude filename

    classes = []
    for match in re.finditer(r'class\s+(\w+)(\s+extends\s+(\w+))?', content):
        class_name = match.group(1)
        superclass = match.group(3)
        body_start = match.end()
        body = extract_class_body(content[body_start:])
        fields, methods = extract_members(body)
        classes.append((class_name, superclass, fields, methods))

    return namespace or "lib", classes

def extract_class_body(content):
    brace_count = 0
    body = ""
    for i, char in enumerate(content):
        body += char
        if char == '{':
            brace_count += 1
        elif char == '}':
            brace_count -= 1
            if brace_count == 0:
                break
    return body

def extract_members(body):
    lines = body.splitlines()
    fields = []
    methods = []
    for line in lines:
        line = line.strip()
        if not line or line.startswith("//"): continue

        if "(" in line and ")" in line:
            m = re.match(r'(?:static\s+)?(?:[\w<>]+)?\s*(\w+)\s*\((.*?)\)', line)
            if m:
                method_name = m.group(1)
                visibility = get_visibility(method_name)
                is_static = "static" in line
                return_type = extract_return_type(line)
                methods.append((visibility, method_name, return_type, is_static))
        else:
            m = re.match(r'(?:final|var|const)?\s*(?:[\w<>]+)?\s*(\w+);', line)
            if m:
                field_name = m.group(1)
                visibility = get_visibility(field_name)
                is_static = "static" in line
                field_type = extract_return_type(line)
                fields.append((visibility, field_name, field_type, is_static))

    return fields, methods

def get_visibility(name):
    return '-' if name.startswith('_') else '+'

def extract_return_type(line):
    parts = re.split(r'\s+', line.strip())
    for i in range(len(parts) - 1):
        if '(' in parts[i+1]:  # function
            return parts[i]
        elif parts[i+1].endswith(";"):  # variable
            return parts[i]
    return "void"

def generate_puml(namespace, classes, output_file):
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("@startuml\n\n")
        f.write(f"package {namespace} {{\n\n")

        for cls, superclass, fields, methods in classes:
            f.write(f"class {cls} {{\n")
            for vis, name, typ, is_static in fields:
                static = "{static} " if is_static else ""
                f.write(f"  {vis} {static}{name} : {typ}\n")
            for vis, name, typ, is_static in methods:
                static = "{static} " if is_static else ""
                f.write(f"  {vis} {static}{name}() : {typ}\n")
            f.write("}\n\n")
            if superclass:
                f.write(f"{superclass} <|-- {cls}\n\n")

        f.write("}\n\n@enduml\n")

def scan_lib_and_generate(lib_path: str, output_path: str):
    lib_root = Path(lib_path).resolve()
    output_dir = Path(output_path).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    for dart_file in lib_root.rglob("*.dart"):
        namespace, classes = parse_dart_file(dart_file, lib_root)
        if not classes:
            continue
        output_file = output_dir / dart_file.with_suffix('.puml').name
        generate_puml(namespace, classes, output_file)
        print(f"Generated: {output_file}")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Generate PUML files for each Dart file in lib.")
    parser.add_argument("--lib", default="lib", help="Path to lib folder")
    parser.add_argument("--out", default="puml_output", help="Output folder for .puml files")
    args = parser.parse_args()

    scan_lib_and_generate(args.lib, args.out)
