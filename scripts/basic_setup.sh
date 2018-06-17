TARGET_PATH=/opt
TARGET_TAR=basic.tar.gz

mkdir -p "$TARGET_PATH"
echo "Untar the $TARGET_TAR to $TARGET_PATH"
(cd "$TARGET_PATH"; tar -xzf -) < $TARGET_TAR

export BASIC_DIR=/opt/basic
