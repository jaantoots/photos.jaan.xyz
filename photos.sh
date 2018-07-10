#!/bin/bash

exif() {
    grep -s -m 1 -e "^$1\s*:" <<<"$exif" | cut -d ':' -f 2- | cut -c 2-
}

image_info() {
    s=" | " # field separator
    exec 2>/dev/null

    exif=$(exiftool -c '%.6f' -d '%F %T' "$1")

    geometry="$(exif "Image Size")"
    focal="$(exif "Focal Length")"
    exposure="$(exif "Exposure Time")"
    aperture="$(exif "F Number")"
    iso="$(exif "ISO")"
    gps="$(exif "GPS Position")"
    date="$(exif "Date/Time Original")"
    if [ -z "$date" ]; then
        date="$(date --date="@$(stat -c '%Y' "$1")" +'%F %T')"
    fi

    echo "${geometry}${focal:+$s}${focal}${exposure:+$s}${exposure}${aperture:+${s}F}${aperture}${iso:+${s}ISO }${iso}${gps:+$s}${gps}${date:+$s}${date}"
}

for img in $1/*.jpg; do
    thumb="${img%.jpg}.1200x800.jpg"
    convert "$img" -colorspace RGB -resize 1200x800^ -colorspace sRGB "$thumb" 
    printf '{{< photo full="%s" thumb="%s" alt="%s" phototitle="" description="%s">}}\n' \
        "$(basename "$img")" "$(basename "$thumb")" "$(basename "$img")" "$(image_info "$img")"
done
