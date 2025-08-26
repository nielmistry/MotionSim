#!/bin/bash
#
# PCB Manufacturing Files Generator
# 
# This script generates manufacturing files (PDFs, Gerbers, Drill files) from KiCad PCB files
# using Docker to ensure consistent results across different environments.
#
# Requirements:
# - Docker installed and running
# - KiCad PCB files in MotionSimPCB/ directory
#
# Usage:
#   ./generate-pcb-files.sh
#

set -e

echo "🔧 Motion Simulator PCB Manufacturing Files Generator"
echo "=================================================="

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is required but not installed. Please install Docker and try again."
    exit 1
fi

# Check if PCB files exist
if [ ! -f "MotionSimPCB/MotionSimPCB.kicad_pcb" ]; then
    echo "❌ PCB file not found. Please run this script from the repository root."
    exit 1
fi

# Create output directories
echo "📁 Creating output directories..."
mkdir -p assets/{pdfs,gerbers,drill}
chmod -R 755 assets

# Setup KiCad environment for Docker
echo "⚙️  Setting up KiCad environment..."
mkdir -p /tmp/kicad-home/.cache /tmp/kicad-home/.config/kicad/9.0
chmod -R 777 /tmp/kicad-home

# Pull KiCad Docker image
echo "📥 Pulling KiCad Docker image..."
docker pull kicad/kicad:9.0

echo ""
echo "🔄 Generating manufacturing files..."

# Generate PDFs from Schematics
echo "  📄 Generating schematic PDFs..."
set +e  # Don't exit on error for individual steps

# Try to generate main schematic PDF
docker run --rm \
  -e HOME=/tmp/kicad-home \
  -v "/tmp/kicad-home:/tmp/kicad-home" \
  -v "$PWD:/workspace" \
  -w /workspace \
  kicad/kicad:9.0 \
  sh -c "kicad-cli sch export pdf MotionSimPCB/MotionSimPCB.kicad_sch && mv MotionSimPCB.pdf assets/pdfs/MotionSimPCB-schematic.pdf" 2>/dev/null

# Fallback to existing PDF if generation failed
if [ ! -f "assets/pdfs/MotionSimPCB-schematic.pdf" ]; then
    echo "    ⚠️  KiCad PDF generation failed, checking for existing PDFs..."
    if [ -f "MotionSimPCB/pdfs/MotionSimPCB.pdf" ]; then
        echo "    ✅ Found existing PDF, copying..."
        cp "MotionSimPCB/pdfs/MotionSimPCB.pdf" "assets/pdfs/MotionSimPCB-schematic.pdf"
    else
        echo "    ❌ No existing PDF found"
    fi
fi

# Try to generate controllers schematic PDF
docker run --rm \
  -e HOME=/tmp/kicad-home \
  -v "/tmp/kicad-home:/tmp/kicad-home" \
  -v "$PWD:/workspace" \
  -w /workspace \
  kicad/kicad:9.0 \
  sh -c "kicad-cli sch export pdf MotionSimPCB/controllers.kicad_sch && mv controllers.pdf assets/pdfs/controllers-schematic.pdf" 2>/dev/null

if [ ! -f "assets/pdfs/controllers-schematic.pdf" ]; then
    echo "    ⚠️  Controllers schematic PDF generation failed"
fi

# Try to generate PCB PDF  
echo "  📄 Generating PCB layout PDF..."
docker run --rm \
  -e HOME=/tmp/kicad-home \
  -v "/tmp/kicad-home:/tmp/kicad-home" \
  -v "$PWD:/workspace" \
  -w /workspace \
  kicad/kicad:9.0 \
  sh -c "kicad-cli pcb export pdf --layers 'F.Cu,B.Cu,F.Silkscreen,B.Silkscreen,Edge.Cuts' MotionSimPCB/MotionSimPCB.kicad_pcb && mv MotionSimPCB.pdf assets/pdfs/MotionSimPCB-pcb.pdf" 2>/dev/null

if [ ! -f "assets/pdfs/MotionSimPCB-pcb.pdf" ]; then
    echo "    ⚠️  PCB PDF generation failed"
fi

# Generate Gerber files
echo "  🏭 Generating Gerber files..."
docker run --rm \
  -e HOME=/tmp/kicad-home \
  -v "/tmp/kicad-home:/tmp/kicad-home" \
  -v "$PWD:/workspace" \
  -w /workspace \
  kicad/kicad:9.0 \
  sh -c "kicad-cli pcb export gerbers --layers 'F.Cu,B.Cu,F.Paste,B.Paste,F.Silkscreen,B.Silkscreen,F.Mask,B.Mask,Edge.Cuts' MotionSimPCB/MotionSimPCB.kicad_pcb && mv MotionSimPCB-*.g* assets/gerbers/" 2>/dev/null

# Generate drill files
echo "  🔩 Generating drill files..."
docker run --rm \
  -e HOME=/tmp/kicad-home \
  -v "/tmp/kicad-home:/tmp/kicad-home" \
  -v "$PWD:/workspace" \
  -w /workspace \
  kicad/kicad:9.0 \
  sh -c "kicad-cli pcb export drill --format excellon MotionSimPCB/MotionSimPCB.kicad_pcb && mv MotionSimPCB*.drl assets/drill/" 2>/dev/null

set -e  # Re-enable exit on error

# Create manufacturing package
echo "  📦 Creating manufacturing package..."
cd assets

if [ "$(ls -A gerbers/ 2>/dev/null)" ] && [ "$(ls -A drill/ 2>/dev/null)" ]; then
    echo "    ✅ Creating manufacturing ZIP with generated files..."
    zip -r ../MotionSimPCB-manufacturing-files.zip gerbers/ drill/
else
    echo "    ⚠️  Manufacturing file generation incomplete, creating instruction package..."
    mkdir -p ../manufacturing-instructions
    cat > ../manufacturing-instructions/README.md << EOF
# Manufacturing Files Generation

The automated generation of Gerber and drill files had issues.

## Manual Generation Steps

1. Install KiCad (version 9.0 or compatible)
2. Open MotionSimPCB/MotionSimPCB.kicad_pcb in KiCad
3. Generate Gerbers:
   - Go to File > Fabrication Outputs > Gerbers
   - Select appropriate layers and options
   - Generate files
4. Generate Drill Files:
   - Go to File > Fabrication Outputs > Drill Files
   - Select Excellon format
   - Generate files
5. Package the .gbr and .drl files for your PCB manufacturer

## PCB Specifications

- 2-layer PCB
- Standard 1.6mm thickness recommended
- HASL or ENIG surface finish
- Standard green solder mask
- White silkscreen
EOF
    
    # Copy source files for reference
    cp ../MotionSimPCB/MotionSimPCB.kicad_pcb ../manufacturing-instructions/
    cp ../MotionSimPCB/MotionSimPCB.kicad_pro ../manufacturing-instructions/
    
    zip -r ../MotionSimPCB-manufacturing-files.zip ../manufacturing-instructions/
fi

cd ..

# Show results
echo ""
echo "✅ Generation complete!"
echo ""
echo "📊 Results:"
echo "==========="

if [ -f "assets/pdfs/MotionSimPCB-schematic.pdf" ]; then
    echo "✅ Schematic PDF: assets/pdfs/MotionSimPCB-schematic.pdf"
else
    echo "❌ Schematic PDF: Failed to generate"
fi

if [ -f "assets/pdfs/controllers-schematic.pdf" ]; then
    echo "✅ Controllers PDF: assets/pdfs/controllers-schematic.pdf"
else
    echo "❌ Controllers PDF: Failed to generate"
fi

if [ -f "assets/pdfs/MotionSimPCB-pcb.pdf" ]; then
    echo "✅ PCB Layout PDF: assets/pdfs/MotionSimPCB-pcb.pdf"
else
    echo "❌ PCB Layout PDF: Failed to generate"
fi

gerber_count=$(ls assets/gerbers/*.g* 2>/dev/null | wc -l || echo 0)
if [ "$gerber_count" -gt 0 ]; then
    echo "✅ Gerber files: $gerber_count files in assets/gerbers/"
else
    echo "❌ Gerber files: None generated"
fi

drill_count=$(ls assets/drill/*.drl 2>/dev/null | wc -l || echo 0)
if [ "$drill_count" -gt 0 ]; then
    echo "✅ Drill files: $drill_count files in assets/drill/"
else
    echo "❌ Drill files: None generated"
fi

if [ -f "MotionSimPCB-manufacturing-files.zip" ]; then
    echo "✅ Manufacturing package: MotionSimPCB-manufacturing-files.zip"
    echo ""
    echo "📋 Package contents:"
    unzip -l MotionSimPCB-manufacturing-files.zip
else
    echo "❌ Manufacturing package: Failed to create"
fi

echo ""
echo "🎉 Done! Check the assets/ directory for all generated files."

# Cleanup
rm -rf /tmp/kicad-home 2>/dev/null || true