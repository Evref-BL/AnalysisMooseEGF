Class {
	#name : #EGFTraceModel,
	#superclass : #Object,
	#instVars : [
		'rawStack',
		'traces',
		'importedOtelTraces'
	],
	#category : #AnalysisMooseEGF
}

{ #category : #'instance creation' }
EGFTraceModel class >> newFromRawStack: aString [
	|t|
	t := EGFTraceModel new rawStack: aString. 
	t computeTrace. 
	^ t. 
]

{ #category : #accessing }
EGFTraceModel >> compute [

	traces := OrderedDictionary new.
	importedOtelTraces do: [ :trace | 
		| otlTrace |

		otlTrace := OtelTrace new
			            spanID: (trace at: #id);
			            parentID: (trace at: #parentId ifAbsent: nil);
			            traceID: (trace at: #traceId);
			            timestamp: (trace at: #timestamp);
			            methodSignature:
				            (trace at: #tags at: 'drit.in_method_named').
		traces at: otlTrace spanID put: otlTrace ]
]

{ #category : #accessing }
EGFTraceModel >> importedOtelTraces [

	^ importedOtelTraces
]

{ #category : #accessing }
EGFTraceModel >> importedOtelTraces: anObject [

	importedOtelTraces := anObject
]

{ #category : #'as yet unclassified' }
EGFTraceModel >> initialize [

	rawStack := String new.
	traces := OrderedDictionary new.
	importedOtelTraces := OrderedCollection new
]

{ #category : #accessing }
EGFTraceModel >> rawStack [

	^ rawStack
]

{ #category : #accessing }
EGFTraceModel >> rawStack: anObject [

	rawStack := anObject
]

{ #category : #'as yet unclassified' }
EGFTraceModel >> resolveMethodFromEGFCallflow: aModel [

	self flag: 'Change the number of max traces'.

	traces values from: 100000 to: 133339 do: [ :trace | 
		| identifier nbParms signature candidates filtered |
		signature := trace methodSignature.
		identifier := signature copyFrom: 1 to: (signature indexOf: $().
		"self haltIf: trace spanID = 'ef807332ca378667'."

		nbParms := ((signature
			             copyFrom: (signature indexOf: $()
			             to: (signature indexOf: $))) splitOn: ',') size.
		candidates := aModel methodsNamed: identifier.
		trace
			famixMethodCandidates: candidates;
			"filtered := candidates select: [ :m | 
			            m numberOfParameters = nbParms ].
		filtered isEmpty
			ifTrue: [ trace famixMethodCandidates: candidates ]
			ifFalse: [ trace famixMethodCandidates: filtered ]."
				refineCandidates ]
]

{ #category : #accessing }
EGFTraceModel >> traces [

	^ traces
]

{ #category : #accessing }
EGFTraceModel >> traces: anObject [

	traces := anObject
]
