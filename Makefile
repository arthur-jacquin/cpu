.PHONY: default clean doc

default: doc

asb:
	cc asb.c -o asb

clean:
	(while read FILES; do rm -f $$FILES; done) < .gitignore

doc:
	pdflatex doc

out: asb
	./asb test.asb | tee out
