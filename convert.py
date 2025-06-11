# Correct hash160 for Puzzle #71
hash160_hex = "f6f5431d25bbf7b12e8add9af5e3475c44a0a5b8"
binary = bytes.fromhex(hash160_hex)

# Save to binary file
with open("puzzle71_hash160_sorted.bin", "wb") as f:
    f.write(binary)

print("✅ puzzle71_hash160_sorted.bin created successfully.")
