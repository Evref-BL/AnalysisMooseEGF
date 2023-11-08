Class {
	#name : #JavaProfilerTraceExtractor,
	#superclass : #Object,
	#instVars : [
		'profileFile',
		'xml'
	],
	#category : #AnalysisMooseEGF
}

{ #category : #'as yet unclassified' }
JavaProfilerTraceExtractor >> computeExecutionTrace [

	|trace root|
	trace := EGFTraceModel new. 
	
	"commence "
	(xml firstElement firstElement firstElement ).
	root := (xml root elementsAt: 'tree') firstElement. 
	
	"explore the node label 'tree' of the XML file"
	(self getChildElements: root) do:  [ :node |
		1 halt. 
		"instancier ici le model de donnee des traces"
		
		self getChildElements: node .
		
		 ]
]

{ #category : #accessing }
JavaProfilerTraceExtractor >> getChildElements: aXMLNode [

	^ aXMLNode elements reject: [:m | m isKindOf: XMLString].
]

{ #category : #accessing }
JavaProfilerTraceExtractor >> getChildNodes: aXMLNode [

	1 halt. 
	^ (self getChildElements: aXMLNode). 
]

{ #category : #accessing }
JavaProfilerTraceExtractor >> getChildProperties: aXMLNode [

	1 halt. 
	^ (self getChildElements: aXMLNode). 
]

{ #category : #accessing }
JavaProfilerTraceExtractor >> parseXMLFile: aFileReference [

	profileFile := aFileReference asFileReference.
	xml:= (XMLDOMParser parse: profileFile asFileReference contents) document.
]

{ #category : #accessing }
JavaProfilerTraceExtractor >> profileFile [

	^ profileFile
]

{ #category : #accessing }
JavaProfilerTraceExtractor >> profileFile: aFileReference [

	profileFile := aFileReference
]

{ #category : #accessing }
JavaProfilerTraceExtractor >> xml [

	^ xml
]
