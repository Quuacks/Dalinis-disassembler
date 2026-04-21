# Partial Disassembler

Small 16-bit x86 DOS disassembler written in Assembly (`3ATS.asm`).
The program reads a binary input file byte-by-byte and prints decoded instructions to stdout.

## Features

- Parses file name from command-line arguments (DOS PSP)
- Reads input in 256-byte blocks
- Decodes selected x86 instructions and operand formats
- Prints hexadecimal byte values and decoded instruction text

### Currently decoded instructions

- `DAA`
- `DAS`
- `AAA`
- `AAS`
- `INC`
- `PUSH`
- `SUB`
- `SHR`
- `ROR`

## Project Structure

```text
.
|- 3ATS.asm      ; Source code
|- 3ATS.OBJ      ; Object file (build artifact)
|- 3ATS.EXE      ; Executable (build artifact)
|- 3ATS.MAP      ; Linker map file (build artifact)
`- README.md
```

## Requirements

- DOS environment (or DOS emulator such as DOSBox)
- 16-bit assembler and linker
  - Example: MASM + LINK, or TASM + TLINK

### Example (MASM)

```bat
masm 3ATS.asm;
link 3ATS.obj;
```

### Example (TASM)

```bat
tasm 3ATS.asm
tlink 3ATS.obj
```

## Usage

```bat
3ATS.EXE <input_file>
```

Example:

```bat
3ATS.EXE SAMPLE.BIN
```

If the file cannot be opened or read, the program prints:

```text
Erroras
```

## How It Works (High Level)

1. Reads command-line argument and stores filename.
2. Opens the file in read-only mode via DOS interrupt `21h`.
3. Reads blocks into buffer (`fileBlockBuff`).
4. Processes each byte in `proccess_byte`.
5. Prints decoded instruction and operands.

## Known Limitations

- Partial instruction-set support (not a full x86 disassembler)
- Designed for 16-bit DOS execution model
- Output format is console-oriented and minimal
