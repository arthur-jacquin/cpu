.PHONY: default clean doc out

default: out

asb: asb.c
	cc asb.c -o asb

clean:
	(while read FILES; do rm -rf $$FILES; done) < .gitignore

doc:
	pdflatex doc

out: asb
	./asb test.asb | tee out | awk '{print "    rom(" NR-1 ") <= \"" $$0 "\";"}'
