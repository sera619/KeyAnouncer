import os, shutil, zipfile

source_files = ["KeyAnnouncer.lua", "Utils.lua","KeyAnnouncer.toc", "README.md"]
source_dirs = ["Icons", "Libs"]
destination_folder = os.path.join("dist", "KeyAnnouncer")

def deploy(version):
    clean_up()
    print("Deploy addon in 'dist' folder...")
    zip_file = os.path.join("dist", "KeyAnnouncer-"+version+".zip")
    if not os.path.exists(destination_folder):
        os.makedirs(destination_folder)
    
    for file in source_files:
        if os.path.exists(file):
            shutil.copy(file, destination_folder)
        else:
            print(f"File: {file} not found!")

    for folder in source_dirs:
        if os.path.exists(folder):
            shutil.copytree(folder, os.path.join(destination_folder, folder))
        else:
            print(f"Folder: {folder} not found!")
    
    with zipfile.ZipFile(zip_file, "w", zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(destination_folder):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, os.path.dirname(destination_folder))
                zipf.write(file_path, arcname)
    print("Deploy successfull.")

def clean_up(dist_folder = "dist"):
    if os.path.exists(dist_folder):
        print(f"Cleaning up '{dist_folder}' folder...")
        for item in os.listdir(dist_folder):
            item_path = os.path.join(dist_folder, item)
            if os.path.isfile(item_path) or os.path.islink(item_path):
                os.unlink(item_path)
            elif os.path.isdir(item_path):
                shutil.rmtree(item_path)
        print(f"{dist_folder} folder cleaned.")
    else:
        print(f"Folder {dist_folder} does not exists. No cleanup needed.")

def main():
    options = ["1) Deploy", "2) Clean up", "0) Exit"]
    print("KeyAnnouncer Packager\n")
    for o in options:
        print(o)
    choose = input("Select a option (1-0): ")
    if int(choose) == 1:
        global version
        version = input("Enter version: ")
        deploy(version)
    elif int(choose) == 2:
        clean_up()
    elif int(choose) == 0:
        print("Exit, bye!")
        exit()
    else:
        print("Invalid option! Start again!")
        exit()


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print("An error occured:\n", e)
    