.PHONY: all pdf html python_pdf python_html data_pdf data_html django_pdf django_html

# Define the general resume source and output filenames
RESUME_SOURCE=resume
PDF_OUTPUT=Andrew\ Grossman\ -\ Resume.pdf
HTML_OUTPUT=Andrew\ Grossman\ -\ Resume.html

# Define the specific resume sources and output filenames
PYTHON_SOURCE=resume-python-focus
DATA_SOURCE=resume-data-ic-focus
DJANGO_SOURCE=resume-django-ic-focus

PYTHON_PDF_OUTPUT=Andrew\ Grossman\ -\ Python\ -\ Resume.pdf
PYTHON_HTML_OUTPUT=Andrew\ Grossman\ -\ Python\ -\ Resume.html

DATA_PDF_OUTPUT=Andrew\ Grossman\ -\ Data\ -\ Resume.pdf
DATA_HTML_OUTPUT=Andrew\ Grossman\ -\ Data\ -\ Resume.html

DJANGO_PDF_OUTPUT=Andrew\ Grossman\ -\ Django\ -\ Resume.pdf
DJANGO_HTML_OUTPUT=Andrew\ Grossman\ -\ Django\ -\ Resume.html

# Command to generate general PDF resume
pdf:
	node_modules/.bin/resume export $(PDF_OUTPUT) --resume $(RESUME_SOURCE).json --theme jsonresume-theme-relaxed

# Command to generate general HTML resume
html:
	node_modules/.bin/resume export $(HTML_OUTPUT) --resume $(RESUME_SOURCE).json --theme jsonresume-theme-relaxed

# Command to generate Python-focused PDF resume
python_pdf:
	node_modules/.bin/resume export $(PYTHON_PDF_OUTPUT) --resume $(PYTHON_SOURCE).json --theme jsonresume-theme-relaxed

# Command to generate Python-focused HTML resume
python_html:
	node_modules/.bin/resume export $(PYTHON_HTML_OUTPUT) --resume $(PYTHON_SOURCE).json --theme jsonresume-theme-relaxed

# Command to generate Data-focused PDF resume
data_pdf:
	node_modules/.bin/resume export $(DATA_PDF_OUTPUT) --resume $(DATA_SOURCE).json --theme jsonresume-theme-relaxed

# Command to generate Data-focused HTML resume
data_html:
	node_modules/.bin/resume export $(DATA_HTML_OUTPUT) --resume $(DATA_SOURCE).json --theme jsonresume-theme-relaxed

# Command to generate Django-focused PDF resume
django_pdf:
	node_modules/.bin/resume export $(DJANGO_PDF_OUTPUT) --resume $(DJANGO_SOURCE).json --theme jsonresume-theme-relaxed

# Command to generate Django-focused HTML resume
django_html:
	node_modules/.bin/resume export $(DJANGO_HTML_OUTPUT) --resume $(DJANGO_SOURCE).json --theme jsonresume-theme-relaxed

# Build all resumes (PDF and HTML for general, Python, Data, and Django)
all: pdf html python_pdf python_html data_pdf data_html django_pdf django_html
