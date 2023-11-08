Class {
	#name : #FamixJVMProfilerImporter,
	#superclass : #Object,
	#instVars : [
		'extractor',
		'loader',
		'transformers'
	],
	#category : #'Famix-JavaProfiler-Importer'
}

{ #category : #accessing }
FamixJVMProfilerImporter >> extractor [

	^ extractor
]

{ #category : #accessing }
FamixJVMProfilerImporter >> extractor: anExtractor [

	extractor := anExtractor
]

{ #category : #accessing }
FamixJVMProfilerImporter >> import [

	"Import traces into a model using the configured extractor, loader and transformers."

	| data |
	data := extractor extract. "obtain raw data"
	data := loader load: data. "data becomes model"

	^ data
]

{ #category : #accessing }
FamixJVMProfilerImporter >> loader [

	^ loader
]

{ #category : #accessing }
FamixJVMProfilerImporter >> loader: anObject [

	loader := anObject
]
