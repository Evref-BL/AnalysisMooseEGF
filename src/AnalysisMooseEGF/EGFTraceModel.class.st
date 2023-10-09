Class {
	#name : #EGFTraceModel,
	#superclass : #Object,
	#instVars : [
		'rawStack',
		'importedOtelTraces',
		'tracesInOrder',
		'tracesGrpBySignature'
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
EGFTraceModel >> importedOtelTraces [

	^ importedOtelTraces
]

{ #category : #accessing }
EGFTraceModel >> importedOtelTraces: anObject [

	importedOtelTraces := anObject
]

{ #category : #accessing }
EGFTraceModel >> initTraces [

	tracesInOrder := OrderedDictionary new.
	tracesGrpBySignature := Dictionary new. 
	importedOtelTraces do: [ :trace | 
		| otlTrace |
		otlTrace := OtelTrace new
			            spanID: (trace at: #id ifAbsent: nil);
			            parentID: (trace at: #parentId ifAbsent: nil);
			            traceID: (trace at: #traceId ifAbsent: nil);
			            timestamp: (trace at: #timestamp ifAbsent: nil);
			            methodSignature:
				            (trace at: #tags at: 'drit.method' ifAbsent: nil);
			            order: (trace at: #tags at: 'drit.order' ifAbsent: nil).

		tracesInOrder at: otlTrace spanID put: otlTrace.
		
		tracesGrpBySignature at: otlTrace methodSignature ifPresent: [ :elmnt | elmnt add: otlTrace. ] ifAbsentPut: [ |array| array := OrderedCollection new. array add: otlTrace.  array. ] .
		 ]
]

{ #category : #'as yet unclassified' }
EGFTraceModel >> initialize [

	rawStack := String new.
	tracesInOrder := OrderedDictionary new.
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
EGFTraceModel >> refineCandidates: candidates withSignature: methodSignature [

	| filtered parms nbParms|
	nbParms := 0.
	filtered := OrderedCollection new.
	
	"check for the same number of parameter"
	parms := (methodSignature
		          copyFrom: (methodSignature indexOf: $() + 1
		          to: (methodSignature indexOf: $)) - 1) splitOn: ','.

	parms first isEmptyOrNil ifFalse: [ nbParms := parms size ].

	filtered := candidates select: [ :m | m numberOfParameters = nbParms ].
	"check if the paremeters are of the same type "
	filtered := filtered select: [ :m | 
		            | mtdParms check mooseSignature parmNames orderedMooseParams|
		            check := true.
		
						"regexMtdSignature := (m mooseNameWithDots) replaceAllRegex: '<.*>' with: ''."
		            parmNames := m parameters.
						
						
						"Sort parameter of the Famix method by their position in sourceText"
						mooseSignature := m sourceText copyFrom: 1 to: (((m sourceText) indexOf: ${) -1).
						"obtain position in source code of each parm"
						orderedMooseParams := parmNames collect: [:p |
							|name|
							name := p name.
							p -> (mooseSignature findString: name).
							  ].
						"sort them by position"
						parmNames := (orderedMooseParams sort: [ :x :y | x value < y value ]) collect: [ :asso | asso key ].
						
						
						
						1 to: nbParms do: [ :i | 
			            | parmMoose parmTrace |
							
							parmMoose := (parmNames at: i) declaredType name.
							parmTrace := parms at: i. 
							
							((parmMoose includesSubstring: parmTrace) or: [ 
				             parmTrace includesSubstring: parmMoose ]) ifFalse: [ 
				            check := false ].
							
						
							
			            "parmMoose := (mtdParms at: i) replaceAllRegex: '<.*>' with: ''.
			            parmTrace := (parms at: i) replaceAllRegex: '<.*>' with: ''.

			            ((parmMoose includesSubstring: parmTrace) or: [ 
				             parmTrace includesSubstring: parmMoose ]) ifFalse: [ 
				            check := false ]" ].
		
		            check ].

	^ filtered .

	"""if the filtered are empty, we return the initial candidate list instead""
	filtered isEmpty
		ifTrue: [ ^ candidates ]
		ifFalse: [ ^ filtered ]"
]

{ #category : #'as yet unclassified' }
EGFTraceModel >> resolveMethodFromEGFCallflow: aModel [

	| min max |
	self
		deprecated: 'Use #resolveMethodFromEGFCallflowV2: instead'
		on: '6 October 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.
	self flag: 'Change the number of max traces'.
	min := 1.
	max := tracesInOrder values size / 1.

	tracesInOrder values from: min to: max do: [ :trace | 
		| identifier nbParms signature candidates "filtered" |
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

{ #category : #'as yet unclassified' }
EGFTraceModel >> resolveMethodFromEGFCallflowV2: aModel [

	tracesGrpBySignature keysDo: [ :signature | 
		| identifier candidates "filtered" |
		identifier := signature copyFrom: 1 to: (signature indexOf: $().


		candidates := aModel methodsNamed: identifier.
		candidates := self
			              refineCandidates: candidates
			              withSignature: signature.


		(tracesGrpBySignature at: signature) do: [ :trace | 
			trace famixMethodCandidates: candidates ] ].

	tracesGrpBySignature := (tracesGrpBySignature associations reject: [ 
		                        :assoc | 
		                        assoc value anyOne famixMethodCandidates
			                        isEmpty ]) asDictionary .

	^ self
]

{ #category : #accessing }
EGFTraceModel >> traces [

	^ tracesInOrder
]

{ #category : #accessing }
EGFTraceModel >> traces: anObject [

	tracesInOrder := anObject
]

{ #category : #accessing }
EGFTraceModel >> tracesGrpBySignature [

	^ tracesGrpBySignature
]
