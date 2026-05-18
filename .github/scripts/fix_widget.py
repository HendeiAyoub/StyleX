import re

with open('ShoppingApp.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

original_len = len(content.splitlines())

# 1. Remove the embed phase line
content = re.sub(r'[^\n]*appex in Embed Foundation Extensions[^\n]*\n', '', content)

# 2. Remove the explicit target dependency line from ShoppingApp's dependencies array
content = re.sub(r'[^\n]*ShoppingAppWidgetExtension[^\n]*/\* ShoppingAppWidgetExtension \*/,[^\n]*\n', '', content)

# 3. Also remove any PBXTargetDependency block referencing the widget
content = re.sub(r'[^\n]*\/\* PBXTargetDependency \*\/[^\n]*\n[^\n]*ShoppingAppWidgetExtension[^\n]*\n[^\n]*\n\s*\};\n', '', content)

# 4. Disable widget code signing
content = content.replace(
    'PRODUCT_BUNDLE_IDENTIFIER = "com.stylix.tryon.widget";',
    'PRODUCT_BUNDLE_IDENTIFIER = "com.stylix.tryon.widget";\n\t\t\t\tCODE_SIGNING_ALLOWED = NO;\n\t\t\t\tCODE_SIGNING_REQUIRED = NO;'
)

new_len = len(content.splitlines())
print(f"Removed {original_len - new_len} lines")

with open('ShoppingApp.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("Done")
