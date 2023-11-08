Class {
	#name : #FamixJVMProfilerExtractor,
	#superclass : #Object,
	#instVars : [
		'xmlFile',
		'xmlDoc',
		'profile'
	],
	#category : #'Famix-JavaProfiler-Importer'
}

{ #category : #extraction }
FamixJVMProfilerExtractor >> extract [
	^ xmlDoc
]

{ #category : #parsing }
FamixJVMProfilerExtractor >> xmlFile: aFileReference [
	
	xmlDoc := (XMLDOMParser parse: aFileReference asFileReference contents) document.
	
	
]
