Class {
	#name : #EGFDynamicCallFlowModel,
	#superclass : #Object,
	#instVars : [
		'profiler',
		'staticModel'
	],
	#category : #AnalysisMooseEGF
}

{ #category : #accessing }
EGFDynamicCallFlowModel >> compute [
	|steps|
	steps := profiler allWithType: FamixJVMProfilerProcess.
	
	steps do: [ :step |
		|stepSignature stepIdentifier candidates|
		stepSignature := step rawMthSignature.
		stepIdentifier := stepSignature copyFrom: 1 to: (stepSignature indexOf: $( ).
		stepIdentifier := stepIdentifier replaceAllRegex: ' ' with: ''.
		candidates := staticModel methodsNamed: stepIdentifier.
	
		"candidates := self
			              refineCandidates: candidates
			              withSignature: stepSignature."
			candidates isNotEmpty ifTrue: [ 
				candidates := Trace2FamixResolver new  refineCandidates: candidates
			              withSignature: stepSignature.
				 ].
			
			candidates ifNotEmpty: [  	
				
				step origin: candidates first. 	 ].	
		
		 ]
	
]

{ #category : #'as yet unclassified' }
EGFDynamicCallFlowModel >> profilerModel: aFamixJVMProfilerModel [ 
	profiler := aFamixJVMProfilerModel.
]

{ #category : #reset }
EGFDynamicCallFlowModel >> resetModelLinks: anEGFCallflowModel [ 
	anEGFCallflowModel resetTraceProcess.
]

{ #category : #'as yet unclassified' }
EGFDynamicCallFlowModel >> staticModel: anEGFCallflowModel [ 
	staticModel:= anEGFCallflowModel.
]
