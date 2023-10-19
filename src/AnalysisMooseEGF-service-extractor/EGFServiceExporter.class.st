Class {
	#name : #EGFServiceExporter,
	#superclass : #Object,
	#instVars : [
		'exportPath',
		'entities',
		'extractor'
	],
	#category : #'AnalysisMooseEGF-service-extractor'
}

{ #category : #'as yet unclassified' }
EGFServiceExporter >> allModelClassPaths [

	^ (extractor mooseModel allModelClasses collect: [ :c | c sourceAnchor fileName ]) asSet
]

{ #category : #accessing }
EGFServiceExporter >> entities [

	^ entities
]

{ #category : #accessing }
EGFServiceExporter >> entities: anObject [

	entities := anObject
]

{ #category : #public }
EGFServiceExporter >> export [

	| origin allJavaFiles entitiesFiles |
	"set up export folder and copy the project their"
	exportPath asFileReference ensureCreateDirectory.
	exportPath asFileReference children do: [ :f | f deleteAll ].
	origin := extractor mooseModel rootFolder asFileReference.
	origin copyAllTo: exportPath asFileReference.

	"retrive all the java files of the project"
	allJavaFiles := exportPath allChildrenMatching: '*.java'.

	entitiesFiles := self getFilesOutOfEntities:
		                 extractor serviceEntities.

	self removeJavaFilesExcepts: entitiesFiles
]

{ #category : #accessing }
EGFServiceExporter >> exportPath [

	^ exportPath
]

{ #category : #accessing }
EGFServiceExporter >> exportPath: aString [

	exportPath := aString asFileReference
]

{ #category : #accessing }
EGFServiceExporter >> extractor: anObject [

	extractor := anObject
]

{ #category : #'as yet unclassified' }
EGFServiceExporter >> getFilesOutOfEntities: aCollection [

	^ (((aCollection select: [ :item | item respondsTo: #sourceAnchor ]) 
		   collect: [ :item | 
		   item sourceAnchor ifNotNil: [ item sourceAnchor fileName ] ]) reject: #isNil)
		  asSet
]

{ #category : #filtering }
EGFServiceExporter >> removeJavaFilesExcepts: setOfJavaFilesToKeep [ 
	|allJavaFiles pathsToKepp|
	allJavaFiles := (exportPath allChildrenMatching: '*.java').
	""
	pathsToKepp := (setOfJavaFilesToKeep collect: [ :file | exportPath / file ]) asOrderedCollection .
	
	(allJavaFiles \ pathsToKepp ) do: [ :fileRef |
		fileRef delete.
		 ].
	
	
	
]
