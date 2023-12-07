#!/bin/bash

OUTPUT_FILE="function.zip"

# 既存の function.zip ファイルが存在する場合は削除
if [ -f "$OUTPUT_FILE" ]; then
  rm "$OUTPUT_FILE"
fi

# ディレクトリに移動してから圧縮
cd "$SOURCE_DIR" || exit
zip -r "$OUTPUT_FILE" index.js node_modules
cd - || exit

echo "zip complete"