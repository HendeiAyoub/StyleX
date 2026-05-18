import re

with open('ShoppingApp.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Step 1: Find PBXTargetDependency blocks for the widget, collect their UUIDs
dep_matches = list(re.finditer(
    r'\t\t([A-F0-9]{24}) /\* ShoppingAppWidgetExtension \*/ = \{\n\t\t\tisa = PBXTargetDependency;.*?\n\t\t\};\n',
    content, re.DOTALL
))
dep_uuids = [m.group(1) for m in dep_matches]
print(f"PBXTargetDependency blocks found: {len(dep_matches)} → UUIDs: {dep_uuids}")

# Remove those blocks (reversed so indices stay valid)
for m in reversed(dep_matches):
    content = content[:m.start()] + content[m.end():]

# Step 2: Remove their references from ShoppingApp's dependencies array
for uuid in dep_uuids:
    content = re.sub(r'\t+' + uuid + r' /\* ShoppingAppWidgetExtension \*/,\n', '', content)

# Step 3: Find and remove PBXContainerItemProxy blocks for the widget
proxy_matches = list(re.finditer(
    r'\t\t[A-F0-9]{24} /\* PBXContainerItemProxy \*/ = \{\n\t\t\tisa = PBXContainerItemProxy;.*?remoteInfo = ShoppingAppWidgetExtension;.*?\n\t\t\};\n',
    content, re.DOTALL
))
print(f"PBXContainerItemProxy blocks found: {len(proxy_matches)}")
for m in reversed(proxy_matches):
    content = content[:m.start()] + content[m.end():]

# Step 4: Remove embed reference (belt-and-suspenders)
content = re.sub(r'[^\n]*appex in Embed Foundation Extensions[^\n]*\n', '', content)

# Step 5: Disable widget signing in its build configs
replaced = re.subn(
    r'(PRODUCT_BUNDLE_IDENTIFIER = "?com\.stylix\.tryon\.widget"?;)',
    r'\1\n\t\t\t\tCODE_SIGNING_ALLOWED = NO;\n\t\t\t\tCODE_SIGNING_REQUIRED = NO;',
    content
)
content = replaced[0]
print(f"Signing disabled in {replaced[1]} build config(s)")

with open('ShoppingApp.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("Done")
