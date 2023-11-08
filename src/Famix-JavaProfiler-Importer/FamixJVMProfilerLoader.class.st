Class {
	#name : #FamixJVMProfilerLoader,
	#superclass : #Object,
	#instVars : [
		'profileModel',
		'javaModel'
	],
	#category : #'Famix-JavaProfiler-Importer'
}

{ #category : #'as yet unclassified' }
FamixJVMProfilerLoader >> getChildElementsOf: aXMLNode [

	^ aXMLNode elements reject: [:m | m isKindOf: XMLString].
]

{ #category : #'as yet unclassified' }
FamixJVMProfilerLoader >> getChildNodesOf: aXMLNode [

	^ (self getChildElements: aXMLNode). 
]

{ #category : #'as yet unclassified' }
FamixJVMProfilerLoader >> getChildPropertiesOf: aXMLNode [


	^ (self getChildElements: aXMLNode). 
]

{ #category : #accessing }
FamixJVMProfilerLoader >> javaModel [
	^ javaModel ifNil: [ self raiseWarning: 'a java model must be set to properly associate the profiler to the static model'. nil ]. 
]

{ #category : #accessing }
FamixJVMProfilerLoader >> javaModel: aFamixModel [
	javaModel := aFamixModel 
]

{ #category : #loading }
FamixJVMProfilerLoader >> load: xmlDoc [

	
	self loadProfile: xmlDoc.
		
	
	^ self profileModel.
	
]

{ #category : #'as yet unclassified' }
FamixJVMProfilerLoader >> loadProcess: aProcess withProperties: elmts [

elmts elementsAt: #property do: [ :elmt |
		
		((elmt attributeAt: 'name') = 'Name' and: [aProcess rawMthSignature isNil]) ifTrue: [ aProcess rawMthSignature: (elmt attributeAt: 'value') ].
		((elmt attributeAt: 'name') = 'Total Time' and: [aProcess totalTime isNil]) ifTrue: [ aProcess totalTime: (elmt attributeAt: 'value') ].
		((elmt attributeAt: 'name') = 'Total Time (CPU)' and: [aProcess totalTimeCPU isNil]) ifTrue: [ aProcess totalTimeCPU: (elmt attributeAt: 'value') ].
		((elmt attributeAt: 'name') = 'Invocations' and: [aProcess nbInvocations isNil]) ifTrue: [ aProcess nbInvocations: (elmt attributeAt: 'value') ].
		 ].
	aProcess relativeOrder: 1. 
	
	
	^ aProcess.
]

{ #category : #'as yet unclassified' }
FamixJVMProfilerLoader >> loadProfile: aXMLDocument [ 
	
	aXMLDocument elementsAt: 'dataview' do: [ 
		:elm |
		
		self profileModel newProfile name: (elm attributeAt: 'name').
		self visitAndLoadProcesses: (elm elementsAt: 'tree') firstElement firstElement .
		 ]
]

{ #category : #accessing }
FamixJVMProfilerLoader >> profileModel [

	^ profileModel ifNil: [ profileModel := FamixJVMProfilerModel  new ]
]

{ #category : #accessing }
FamixJVMProfilerLoader >> profileModel: aModel [

	profileModel := aModel
]

{ #category : #visiting }
FamixJVMProfilerLoader >> visitAndLoadProcesses: aXMLElement [ 
	|elmts process order|
	
	order := 0. 
	
	elmts := self getChildElementsOf: aXMLElement. 
	process := self profileModel newProcess. 
	self loadProcess: process withProperties: elmts.
	
	
	
	elmts elementsAt: #node do: [ :node |
		|subProcess|
		order := order + 1.
		subProcess := self visitAndLoadProcesses: node. 
		subProcess relativeOrder: order. 
		"subProcess parentProcess: process. "
		process subProcesses add: subProcess.
		 ].
	^ process.
]
