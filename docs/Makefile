all:	user_docs.pdf
#programmer_docs.pdf

user_docs.pdf: user_docs.tex bibliography.bib
	pdflatex user_docs.tex
	bibtex user_docs.aux
	pdflatex user_docs.tex

#programmer_docs.pdf: programmer_docs.tex
#	pdflatex programmer_docs.tex
