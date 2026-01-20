import glob
import os
import subprocess


def compile_latex_files():
    # Identify the directory where this script is located
    script_dir = os.path.dirname(os.path.abspath(__file__))

    # Change current working directory to the script's directory
    os.chdir(script_dir)

    # Find all .tex files in the script's folder
    tex_files = glob.glob(os.path.join(script_dir, "*.tex"))

    if not tex_files:
        print("No .tex files found in the current directory.")
        return

    extensions_to_remove = [".aux", ".log"]

    for tex_file in tex_files:
        file_name = os.path.basename(tex_file)
        print(f"Compiling {file_name}...")

        try:
            # Run pdflatex
            # -interaction=nonstopmode ensures it doesn't wait for user input on errors
            result = subprocess.run(
                ["pdflatex", "-interaction=nonstopmode", file_name],
                check=False,
                capture_output=True,
                text=True,
            )

            if result.returncode == 0:
                print(f"Successfully compiled {file_name}")
            else:
                print(f"Error compiling {file_name}:")
                print(result.stdout)
                print(result.stderr)

        except Exception as e:
            print(f"An error occurred while compiling {file_name}: {e}")

    # Cleanup auxiliary files
    print("\nCleaning up auxiliary files...")
    for ext in extensions_to_remove:
        files_to_delete = glob.glob(os.path.join(script_dir, f"*{ext}"))
        for file_path in files_to_delete:
            try:
                os.remove(file_path)
                print(f"Deleted: {os.path.basename(file_path)}")
            except Exception as e:
                print(f"Error deleting {file_path}: {e}")


if __name__ == "__main__":
    compile_latex_files()
