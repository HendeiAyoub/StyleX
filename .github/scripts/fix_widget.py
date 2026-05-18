import re

with open('ShoppingApp.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Remove widget embed reference
content = re.sub(r'[^\n]*appex in Embed Foundation Extensions[^\n]*\n', '', content)

# Disable widget signing
content = re.sub(
    r'(PRODUCT_BUNDLE_IDENTIFIER = "com\.stylix\.tryon\.widget";)',
    r'\1\n\t\t\t\tCODE_SIGNING_ALLOWED = NO;\n\t\t\t\tCODE_SIGNING_REQUIRED = NO;',
    content
)

with open('ShoppingApp.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("Done")
