
.PHONY: all clean generate_final_forms generate_tailrjsons

OUTPUT_DIR=generated_resumes
GENERATED_JSON_DIR=generated_resume_jsons

# Command to generate intermediate JSON files
generate_tailored_jsons:
	python3 generate_tailored_resume_jsons.py

generate_final_forms:
	mkdir -p $(OUTPUT_DIR)
	for file in $$(ls $(GENERATED_JSON_DIR)/*.json); do \
		name=$$(basename $$file .json); \
		node_modules/.bin/resume export "$(OUTPUT_DIR)/Andrew Grossman - $$name - Resume.pdf" --resume $$file --theme jsonresume-theme-relaxed; \
		node_modules/.bin/resume export "$(OUTPUT_DIR)/Andrew Grossman - $$name - Resume.html" --resume $$file --theme jsonresume-theme-relaxed; \
	done

# Clean the output and generated JSON directories
clean:
	rm -rf $(OUTPUT_DIR)/*
	rm -rf $(GENERATED_JSON_DIR)/*

# Build all resumes (PDF and HTML for general, Python, Data, and Django)
all: generate_tailored_jsons generate_final_forms

