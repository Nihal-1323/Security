#!/usr/bin/env python3
"""
Create ZIP archive of Smart Parking System
"""

import os
import zipfile
from pathlib import Path
from datetime import datetime

def create_zip():
    """Create ZIP file of the project"""
    
    # Get current directory
    script_dir = Path(__file__).parent.absolute()
    parent_dir = script_dir.parent
    
    # Create zip filename with timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    zip_filename = f"smart-parking-system_{timestamp}.zip"
    zip_path = parent_dir / zip_filename
    
    print("=" * 60)
    print("  Smart Parking System - Create ZIP Archive")
    print("=" * 60)
    print(f"\nCreating: {zip_filename}")
    print(f"Location: {parent_dir}\n")
    
    # Files and folders to exclude
    exclude_patterns = [
        '__pycache__',
        '*.pyc',
        '.git',
        '.gitignore',
        '.vscode',
        'create-zip.py',
        '*.zip'
    ]
    
    def should_exclude(file_path):
        """Check if file should be excluded"""
        file_str = str(file_path)
        for pattern in exclude_patterns:
            if pattern.startswith('*.'):
                if file_str.endswith(pattern[1:]):
                    return True
            elif pattern in file_str:
                return True
        return False
    
    # Create ZIP file
    file_count = 0
    total_size = 0
    
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Walk through directory
        for root, dirs, files in os.walk(script_dir):
            # Remove excluded directories
            dirs[:] = [d for d in dirs if not should_exclude(Path(root) / d)]
            
            for file in files:
                file_path = Path(root) / file
                
                # Skip excluded files
                if should_exclude(file_path):
                    continue
                
                # Calculate relative path
                rel_path = file_path.relative_to(script_dir.parent)
                
                # Add to zip
                zipf.write(file_path, rel_path)
                
                file_count += 1
                total_size += file_path.stat().st_size
                
                # Show progress
                if file_count % 10 == 0:
                    print(f"  Added {file_count} files...", end='\r')
    
    # Get zip file size
    zip_size = zip_path.stat().st_size
    compression_ratio = (1 - zip_size / total_size) * 100 if total_size > 0 else 0
    
    print(f"\n\n{'=' * 60}")
    print("  ZIP Archive Created Successfully!")
    print("=" * 60)
    print(f"\nFilename: {zip_filename}")
    print(f"Location: {zip_path}")
    print(f"\nStatistics:")
    print(f"  Files included: {file_count}")
    print(f"  Original size:  {total_size / 1024 / 1024:.2f} MB")
    print(f"  ZIP size:       {zip_size / 1024 / 1024:.2f} MB")
    print(f"  Compression:    {compression_ratio:.1f}%")
    print(f"\n{'=' * 60}\n")
    
    return zip_path

if __name__ == "__main__":
    try:
        zip_path = create_zip()
        print(f"✓ Success! ZIP file created at:\n  {zip_path}\n")
    except Exception as e:
        print(f"\n✗ Error creating ZIP file: {e}\n")
        import traceback
        traceback.print_exc()
