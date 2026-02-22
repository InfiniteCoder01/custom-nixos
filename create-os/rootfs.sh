mkdir "$out"
for ((i = 0; i < ${#targets[@]}; i++)); do
    mkdir -p "$(dirname "$out${targets[$i]}")"
    ln -s "${sources[$i]}" "$out${targets[$i]}"
done

mkdir "$out/proc" "$out/sys" "$out/tmp" "$out/dev" "$out/run"

# Copy nix store
mkdir -p "$out/nix/store"
for path in $(< "$closureInfo/store-paths"); do
    cp -a "$path" "$out/$path"
done
