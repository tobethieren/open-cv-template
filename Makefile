LATEXMK=latexmk
LATEXFLAGS=-xelatex -interaction=nonstopmode -file-line-error

.PHONY: all nl en clean distclean

all: nl en

nl:
	mkdir -p build/nl
	cd src/nl && $(LATEXMK) $(LATEXFLAGS) -output-directory=../../build/nl main.tex
	cp build/nl/main.pdf build/cv-template-nl.pdf

en:
	mkdir -p build/en
	cd src/en && $(LATEXMK) $(LATEXFLAGS) -output-directory=../../build/en main.tex
	cp build/en/main.pdf build/cv-template-en.pdf

clean:
	rm -rf build/nl build/en
	rm -f build/cv-template-nl.pdf build/cv-template-en.pdf
	mkdir -p build/nl build/en

distclean: clean
