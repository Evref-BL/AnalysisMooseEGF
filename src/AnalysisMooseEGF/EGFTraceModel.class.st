Class {
	#name : #EGFTraceModel,
	#superclass : #Object,
	#instVars : [
		'rawStack',
		'spansByMethods',
		'spanById',
		'importedOTelTrace',
		'cachedReferences'
	],
	#category : #AnalysisMooseEGF
}

{ #category : #initialize }
EGFTraceModel class >> newFromFamixOTelModel: aFamixOTelModel [

	"model := OpenTelemetryImporter importFromJavaLogFile: 	'/path/to/Console-exporter-logging-16102023-clean-subset.log'."

	| traces |
	traces := EGFTraceModel new.
	traces importOTelTracesFromModel: aFamixOTelModel.
	^ traces
]

{ #category : #'instance creation' }
EGFTraceModel class >> newFromRawStack: aString [
	|t|
	t := EGFTraceModel new rawStack: aString. 
	t computeTrace. 
	^ t. 
]

{ #category : #importer }
EGFTraceModel >> importOTelTracesFromModel: aFamixOTelModel [

	| spans |
	spans := aFamixOTelModel entities select: [ :entity | 
		         entity className = #FamixOTelSpan ].

	spanById := OrderedDictionary new.
	spansByMethods := Dictionary new.

	spans do: [ :span | 
		| OTSpan |

		OTSpan := OTelSpanProxy newFrom: span.
		

		spanById at: OTSpan spanID put: OTSpan.

		spansByMethods
			at: OTSpan methodSignature
			ifPresent: [ :elmnt | elmnt add: OTSpan ]
			ifAbsentPut: [ 
				| array |
				array := OrderedCollection new.
				array add: OTSpan.
				array ] ]
]

{ #category : #accessing }
EGFTraceModel >> importedOtelTraces [

	^ importedOTelTrace
]

{ #category : #accessing }
EGFTraceModel >> importedOtelTraces: anObject [

	importedOTelTrace := anObject
]

{ #category : #'as yet unclassified' }
EGFTraceModel >> initialize [

	rawStack := String new.
	spanById := OrderedDictionary new.
	importedOTelTrace := OrderedCollection new.
	cachedReferences := Dictionary new.
]

{ #category : #accessing }
EGFTraceModel >> initializingSpans [

	spanById := OrderedDictionary new.
	spansByMethods := Dictionary new.
	importedOTelTrace do: [ :trace | 
		trace do: [ :rawSpan |
			| otlTrace |
		otlTrace := OTelSpan new
			            spanID: (rawSpan at: #id ifAbsent: nil);
			            parentID: (rawSpan at: #parentId ifAbsent: nil);
			            traceID: (rawSpan at: #traceId ifAbsent: nil);
			            timestamp: (rawSpan at: #timestamp ifAbsent: nil);
			            methodSignature:
				            (rawSpan at: #tags at: 'drit.method' ifAbsent: nil);
			            order: (rawSpan at: #tags at: 'drit.order' ifAbsent: nil);
			            stackcall:
				            (rawSpan at: #tags at: 'drit.stackcall' ifAbsent: nil);
			            threadID:
				            (rawSpan at: #tags at: 'thread.id' ifAbsent: nil).

		spanById at: otlTrace spanID put: otlTrace.

		spansByMethods
			at: otlTrace methodSignature
			ifPresent: [ :elmnt | elmnt add: otlTrace ]
			ifAbsentPut: [ 
				| array |
				array := OrderedCollection new.
				array add: otlTrace.
				array ] 
			 ]
		
		]
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
EGFTraceModel >> resolveFamixMethodWithEGFCallflow: aModel [


	spansByMethods keysDo: [ :signature | 
		| identifier candidates "filtered" |
		identifier := signature copyFrom: 1 to: (signature indexOf: $().


		candidates := aModel methodsNamed: identifier.
		candidates := self
			              refineCandidates: candidates
			              withSignature: signature.


		(spansByMethods at: signature) do: [ :trace | 
			trace famixMethodCandidates: candidates ] ].

	spansByMethods := (spansByMethods associations reject: [ 
		                        :assoc | 
		                        assoc value anyOne famixMethodCandidates
			                        isEmpty ]) asDictionary .

	^ self
]

{ #category : #'as yet unclassified' }
EGFTraceModel >> resolveIncomingFamixMethodWithEGFCallflow: aModel [


	cachedReferences at: #access ifAbsentPut: [ OrderedCollection new. ].
	cachedReferences at: #notInModel ifAbsentPut: [ OrderedCollection new. ].

	spanById do: [ :span |
		|fromSignature res|
		
		"NOTE 
		some signature can be of a synthetic method, refered by 'access$0' in the signature. 
		A synthetic method in Java is a method that is generated by the Java compiler rather than being explicitly written in the source code by the programmer. 
		access$0 is the synthetic method created to access a private member of the enclosing class."
		fromSignature  := span stackcall copyFrom: 1 to: (span stackcall indexOf:$()-1.
		
		(fromSignature at: (fromSignature size)) = $> ifTrue: [
			| constructorName|
			fromSignature := (fromSignature copyFrom: 1 to: (fromSignature lastIndexOf:$.)-1).
			constructorName := fromSignature copyFrom: (fromSignature lastIndexOf:$.) to: fromSignature size.
			fromSignature := fromSignature ,constructorName.
			 
			].
		
		res := span famixMethodCandidates collect: [ :famixMth|
			|invocs|
		
			invocs := aModel invokingMethodsOf: famixMth.
			invocs select: [ :invokingMethods |
				|signature|
				
				signature := invokingMethods mooseNameWithDotsJVMFormat copyFrom: 1 to: (invokingMethods mooseNameWithDotsJVMFormat indexOf:$()-1.
				signature = fromSignature.
				 ].		
			 ].
		
		
		res flatten isEmpty ifTrue: [ 
			(fromSignature includesSubstring: 'access') ifTrue: [ (cachedReferences at: #access) add: span stackcall . ] ifFalse: [
				(cachedReferences at: #notInModel) add: span stackcall .
				].
			
			].
		
			span famixIncomingMethodCandidates: res flatten . 
		 ].

	"

	spansByMethods keysDo: [ :signature | 
		| identifier candidates ""filtered"" |
		
		
		identifier := signature copyFrom: 1 to: (signature indexOf: $().


		candidates := aModel methodsNamed: identifier.
		candidates := self
			              refineCandidates: candidates
			              withSignature: signature.


		(spansByMethods at: signature) do: [ :trace | 
			trace famixMethodCandidates: candidates ] ].

	spansByMethods := (spansByMethods associations reject: [ 
		                        :assoc | 
		                        assoc value anyOne famixMethodCandidates
			                        isEmpty ]) asDictionary ."

	^ self
]

{ #category : #'as yet unclassified' }
EGFTraceModel >> resolveIncomingFamixMethodWithEGFCallflowV2: aModel [
	|methodsBySignatures|
	cachedReferences removeAll.
	cachedReferences at: #access 
		ifPresent: [ cachedReferences at: #access  put: OrderedCollection new. ] 
		ifAbsentPut: [cachedReferences at: #access  put:  OrderedCollection new. ].
	cachedReferences at: #notinmodel 
		ifPresent: [ cachedReferences at: #access  put: OrderedCollection new. ] 
		ifAbsentPut: [cachedReferences at: #access  put:  OrderedCollection new. ].
	
	methodsBySignatures := aModel flattenMethods keys collect: [ :m | 
		|sig|
		sig := m mooseNameWithDotsJVMFormat copyFrom: 1 
				to: (m mooseNameWithDotsJVMFormat indexOf:$()-1.
		sig -> m
		] .
	
	spanById do: [ :span |
		|fromSignature res|
		
		"NOTE 
		some signature can be of a synthetic method, refered by 'access$0' in the signature. 
		A synthetic method in Java is a method that is generated by the Java compiler rather than being explicitly written in the source code by the programmer. 
		access$0 is the synthetic method created to access a private member of the enclosing class."
		fromSignature  := span stackcall copyFrom: 1 to: (span stackcall indexOf:$()-1.
		
		(fromSignature at: (fromSignature size)) = $> ifTrue: [
			| constructorName|
			fromSignature := (fromSignature copyFrom: 1 to: (fromSignature lastIndexOf:$.)-1).
			constructorName := fromSignature copyFrom: (fromSignature lastIndexOf:$.) to: fromSignature size.
			fromSignature := fromSignature ,constructorName.
			].
		
		res := span famixMethodCandidates collect: [ :famixMth|
			|invocs|
		
			invocs := aModel invokingMethodsOf: famixMth.
			invocs select: [ :invokingMethods |
				|signature|
				
				signature := invokingMethods mooseNameWithDotsJVMFormat copyFrom: 1 
				to: (invokingMethods mooseNameWithDotsJVMFormat indexOf:$()-1.
				signature = fromSignature.
				 ].		
			 ].
	
		res flatten isEmpty ifTrue: [ 
			(fromSignature includesSubstring: 'access') 
			ifTrue: [ (cachedReferences at: #access) add: span . ] 
			ifFalse: [(cachedReferences at: #notinmodel) add: span .].
			].
		
			span famixIncomingMethodCandidates: res flatten . 
		 ].
	

	
	(cachedReferences at: #notinmodel) do: [ :span |
		|fromSignature candidats|
				fromSignature  := span stackcall copyFrom: 1 to: (span stackcall indexOf:$()-1.
				candidats := methodsBySignatures select: [ :assoc | assoc key = fromSignature ].
				
				span famixIncomingMethodCandidates: (candidats collect: #value). 
		 ].
	

	^ self
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
	max := spanById values size / 1.

	spanById values from: min to: max do: [ :trace | 
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

	1 halt. 

	spansByMethods keysDo: [ :signature | 
		| identifier candidates "filtered" |
		identifier := signature copyFrom: 1 to: (signature indexOf: $().


		candidates := aModel methodsNamed: identifier.
		candidates := self
			              refineCandidates: candidates
			              withSignature: signature.


		(spansByMethods at: signature) do: [ :trace | 
			trace famixMethodCandidates: candidates ] ].

	spansByMethods := (spansByMethods associations reject: [ 
		                        :assoc | 
		                        assoc value anyOne famixMethodCandidates
			                        isEmpty ]) asDictionary .

	^ self
]

{ #category : #accessing }
EGFTraceModel >> spanById [

	^ spanById
]

{ #category : #accessing }
EGFTraceModel >> spanById: anObject [

	spanById := anObject
]

{ #category : #accessing }
EGFTraceModel >> spanByMethods [

	^ spansByMethods
]
