#!/bin/bash

bin/lsp-jdtls.sh &&
	bin/lsp-lombok.sh &&
	bin/vscode-java-test.sh &&
	bin/vscode-java-debug.sh 
