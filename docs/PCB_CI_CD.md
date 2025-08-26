# PCB CI/CD Workflows

This repository includes automated CI/CD workflows for generating manufacturing files from KiCad PCB designs.

## 🔧 Automated Workflows

### Pull Request Workflow (`pcb-build.yml`)

**Triggers:** When PCB files in `MotionSimPCB/` are modified in pull requests

**Generates:**
- PDF files from schematics and PCB layout
- Gerber files for PCB manufacturing
- Excellon drill files
- Manufacturing-ready ZIP packages

**Output:** GitHub Actions artifacts with download links automatically posted as PR comments

### Release Workflow (`release.yml`)

**Triggers:** When semantic version tags are pushed (e.g., `v1.0.0`, `v2.1.3`)

**Generates:**
- Versioned PDFs package
- Manufacturing files package
- Complete package with all files
- GitHub release with attached files

**Output:** GitHub release page with downloadable manufacturing files

### Test Workflow (`test-pcb.yml`)

**Triggers:** Manual dispatch or when workflow files are modified

**Purpose:** Validates KiCad setup and tests generation capabilities

## 📁 Generated Files

### PDFs
- `MotionSimPCB-schematic.pdf` - Main schematic diagram
- `controllers-schematic.pdf` - Controllers schematic diagram
- `MotionSimPCB-pcb.pdf` - PCB layout (when generation succeeds)

### Manufacturing Files
- `*.gbr` files - Gerber files for each PCB layer
- `*.drl` files - Excellon drill files
- ZIP packages ready for PCB manufacturers

## 🚀 Usage

### For Contributors (Pull Requests)

1. Modify PCB files in `MotionSimPCB/` directory
2. Create a pull request
3. Wait for CI to complete (usually 2-5 minutes)
4. Download artifacts from the PR comment links
5. Review generated PDFs and manufacturing files

### For Releases

1. Ensure all changes are merged to main branch
2. Create a semantic version tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. GitHub will automatically create a release with manufacturing files
4. Release files are ready for PCB manufacturers

### For Local Generation

Use the included script for local generation:

```bash
./generate-pcb-files.sh
```

**Requirements:**
- Docker installed and running
- PCB files in `MotionSimPCB/` directory

## 🛠️ Manual PCB Manufacturing

If automated generation fails or you prefer manual control:

### Using KiCad GUI

1. **Install KiCad** (version 9.0 or compatible)

2. **Open PCB file:**
   - Launch KiCad
   - Open `MotionSimPCB/MotionSimPCB.kicad_pcb`

3. **Generate Gerber files:**
   - Go to `File > Fabrication Outputs > Gerbers`
   - Select layers:
     - F.Cu (Front Copper)
     - B.Cu (Back Copper)
     - F.Paste (Front Paste)
     - B.Paste (Back Paste)
     - F.Silkscreen (Front Silkscreen)
     - B.Silkscreen (Back Silkscreen)
     - F.Mask (Front Solder Mask)
     - B.Mask (Back Solder Mask)
     - Edge.Cuts (Board Outline)
   - Click "Plot"

4. **Generate drill files:**
   - Go to `File > Fabrication Outputs > Drill Files`
   - Select Excellon format
   - Click "Generate Drill File"

5. **Package for manufacturer:**
   - Zip all `.gbr` and `.drl` files
   - Send to your PCB manufacturer

### PCB Specifications

- **Type:** 2-layer PCB
- **Thickness:** 1.6mm (standard)
- **Surface Finish:** HASL or ENIG recommended
- **Solder Mask:** Green (standard)
- **Silkscreen:** White
- **Via Fill:** Tented vias recommended

## 🔍 Troubleshooting

### Common Issues

**"KiCad generation failed"**
- The workflow will fall back to existing PDFs
- Check the Actions log for detailed error messages
- Use the local generation script for debugging

**"No artifacts available"**
- Ensure PCB files were actually modified in the PR
- Check that file paths match `MotionSimPCB/**`

**Permission errors in local generation**
- Ensure Docker has sufficient permissions
- Try running with `sudo` if necessary
- Check that PCB files are readable

### Getting Help

1. Check the GitHub Actions logs for detailed error messages
2. Review the PCB files for any format compatibility issues
3. Try the local generation script to isolate Docker issues
4. Open an issue if problems persist

## 🔄 Updating Workflows

The workflows are designed to be robust and self-contained. Key features:

- **Fallback mechanisms:** Uses existing PDFs if generation fails
- **Version compatibility:** Uses KiCad 9.0 matching the file format
- **Error handling:** Graceful degradation with informative messages
- **Local testing:** Standalone script for development and debugging

## 📋 File Structure

```
MotionSimPCB/
├── MotionSimPCB.kicad_pcb    # Main PCB layout
├── MotionSimPCB.kicad_sch    # Main schematic
├── controllers.kicad_sch     # Controllers schematic
├── MotionSimPCB.kicad_pro    # Project file
└── pdfs/                     # Existing PDFs (fallback)
    └── MotionSimPCB.pdf

assets/                       # Generated files (gitignored)
├── pdfs/                     # Generated PDFs
├── gerbers/                  # Generated Gerber files
└── drill/                    # Generated drill files

.github/workflows/
├── pcb-build.yml            # PR workflow
├── release.yml              # Release workflow
└── test-pcb.yml             # Test workflow

generate-pcb-files.sh        # Local generation script
```