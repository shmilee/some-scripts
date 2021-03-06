#!/usr/bin/sh
usage() {
    cat <<EOF
Usage: nb2pdf [-art|-rep] file.ipynb
Options:
  -art to article(default)
  -rep to report
  -clean delete *.pdf *.toc *.tex *.out *.log *.aux *_files
EOF
}

TPLX='cjkart'
_out='Article'
if echo $1|grep '^-' 2>&1 >/dev/null; then
    if [ "$1" == '-clean' ]; then
        rm -v *.pdf *.toc *.tex *.out *.log *.aux
        rm -rv *_files
        exit 0
    fi
    if [ "$1" == '-rep' ]; then
        TPLX='cjkrep'
        _out='Report'
    fi
    shift
fi

if [ ${#@} == 0 ]; then
    usage
    exit 0
fi

##BEGIN
for _f in $@; do
    if [ -f "$_f" ];then
        echo
        echo "==> Converting '$_f' to '$_out' ..."
        ipython nbconvert --to pdf --PDFExporter.latex_command="['xelatex', '{filename}']" --LatexExporter.template_file="$TPLX" --LatexExporter.template_path="['cjk_tplx/']" "$_f"
    else
        echo  "==> No file '$_f'!"
    fi
done
