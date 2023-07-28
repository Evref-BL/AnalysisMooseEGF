Class {
	#name : #EGFInvocationModel,
	#superclass : #Object,
	#instVars : [
		'invocationGraph',
		'classGroup',
		'classDependencies',
		'flattenMethods',
		'entryPoint'
	],
	#category : #AnalysisMooseEGF
}

{ #category : #'instance creation' }
EGFInvocationModel class >> newFrom: invocationGraph [

	| invocModel |
	invocModel := EGFInvocationModel new.
	 invocModel initFrom:
		              invocationGraph.
	^ invocModel
]

{ #category : #accessing }
EGFInvocationModel >> classDependencies [
	^ classDependencies
]

{ #category : #setter }
EGFInvocationModel >> classDependencies: aCollection [ 
	classDependencies := aCollection
]

{ #category : #accessing }
EGFInvocationModel >> classGroup [
	^ classGroup
]

{ #category : #setter }
EGFInvocationModel >> classGroup: aCollection [

	classGroup := aCollection.
	"aCollection keys do: [ :key | 
		self classGroup add:
			(EGFClassModel initFrom: key and: (aCollection at: key)) ]"
]

{ #category : #compute }
EGFInvocationModel >> computeClassDependencies [

	"from a invocationGraph based on the methods, outputs the class dependencies of these methods. 
	from A,B two classes and mA, mB two methods,
	if A:mA() invokes B:mB() then the their is a class dependencies from A to B.	
	"

	| recBlock seen classDep |
	self
		deprecated: 'Use #computeClassDependenciesFrom: instead'
		on: '26 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.
	seen := Dictionary new.
	classDep := Dictionary new.


	recBlock := [ :root | "explore next invocation"
	            root keysDo: [ :key | 
		            seen at: key ifAbsent: [ 
			            seen at: key put: true.


			            classDep at: key parentType put: Set new.
			            (root at: key) keysDo: [ :invoc | 
				            classDep
					            at: key parentType
					            ifPresent: [ :v | v add: invoc parentType ]
					            ifAbsent: [ 
						            classDep
							            at: key parentType
							            put: (Set newFrom: { invoc parentType }) ] ].


			            recBlock value: (root at: key) ] ] ].

	invocationGraph valuesDo: [ :dicInvo | 
		dicInvo keysDo: [ :key | recBlock value: (dicInvo at: key) ] ].

	^ classDep
]

{ #category : #compute }
EGFInvocationModel >> computeClassDependenciesFrom: graph [

	"from a invocationGraph based on the methods, outputs the class dependencies of these methods. 
	from A,B two classes and mA, mB two methods,
	if A:mA() invokes B:mB() then the their is a class dependencies from A to B.	
	"

	| recBlock seen classDep |
	self
		deprecated: 'Use #computeClassDependenciesV2From: instead'
		on: '27 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.
	seen := Dictionary new.
	classDep := Dictionary new.


	recBlock := [ :root | "explore next invocation"
	            root keysDo: [ :key | 
		            seen at: key ifAbsent: [ 
			            seen at: key put: true.


			            classDep at: key parentType put: Set new.
			            (root at: key) keysDo: [ :invoc | 
				            classDep
					            at: key parentType
					            ifPresent: [ :v | v add: invoc parentType ]
					            ifAbsent: [ 
						            classDep
							            at: key parentType
							            put: (Set newFrom: { invoc parentType }) ] ].


			            recBlock value: (root at: key) ] ] ].

	graph valuesDo: [ :dicInvo | 
		dicInvo keysDo: [ :key | recBlock value: (dicInvo at: key) ] ].

	^ classDep
]

{ #category : #compute }
EGFInvocationModel >> computeClassDependenciesV2From: methods [

	"from a invocationGraph based on the methods, outputs the class dependencies of these methods. 
	from A,B two classes and mA, mB two methods,
	if A:mA() invokes B:mB() then the their is a class dependencies from A to B.	
	"

	| seen classDeps |
	seen := Dictionary new.
	classDeps := Dictionary new.

	methods keysDo: [ :mth | 
		| class |
		class := mth parentType.

		classDeps
			at: class
			ifPresent: [ :val | 
				val addAll: ((methods at: mth) collect: [ :dep | dep parentType ]) ]
			ifAbsent: [ 
				classDeps
					at: class
					put: ((methods at: mth) collect: [ :dep | dep parentType ]) asSet ] ].


	^ classDeps
]

{ #category : #compute }
EGFInvocationModel >> computeClassGroup [

	| recBlock seen seenClasses |
	self
		deprecated: 'Use #computeClassGroupFrom: instead'
		on: '26 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.

	seen := Dictionary new.
	seenClasses := Dictionary new.


	recBlock := [ :root | 
	            root keysDo: [ :key | "line of code""1 halt."
		            seenClasses
			            at: key parentType
			            ifPresent: [ :v | v add: key ]
			            ifAbsent: [ 
			            seenClasses
				            at: key parentType
				            put: (Set newFrom: { key }) ] ].

	            "explore next invocation"
	            root keysDo: [ :key | 
		            seen at: key ifAbsent: [ 
			            seen at: key put: true.
			            recBlock value: (root at: key) ] ] ].

	invocationGraph valuesDo: [ :dicInvo | 
		dicInvo keysDo: [ :key | recBlock value: (dicInvo at: key) ] ].

	^ seenClasses
]

{ #category : #compute }
EGFInvocationModel >> computeClassGroupFrom: graph [

	| recBlock seen seenClasses |
	self
		deprecated: 'Use #computeClassGroupV2From: instead'
		on: '27 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.
	seen := Dictionary new.
	seenClasses := Dictionary new.


	recBlock := [ :root | 
	            root keysDo: [ :key | "line of code""1 halt."
		            seenClasses
			            at: key parentType
			            ifPresent: [ :v | v add: key ]
			            ifAbsent: [ 
			            seenClasses
				            at: key parentType
				            put: (Set newFrom: { key }) ] ].

	            "explore next invocation"
	            root keysDo: [ :key | 
		            seen at: key ifAbsent: [ 
			            seen at: key put: true.
			            recBlock value: (root at: key) ] ] ].

	graph valuesDo: [ :dicInvo | 
		dicInvo keysDo: [ :key | recBlock value: (dicInvo at: key) ] ].

	^ seenClasses
]

{ #category : #compute }
EGFInvocationModel >> computeClassGroupV2From: methods [

	"return a dictionnary where the class are the keys and their methods are the values "

	| seen seenClasses |
	seen := Dictionary new.
	seenClasses := Dictionary new.



	methods keysDo: [ :meth | 
		| class |
		class := meth parentType.

		seenClasses
			at: class
			ifPresent: [ :v | v add: meth ]
			ifAbsent: [ seenClasses at: class put: (Set newFrom: { meth }) ] ].
		
		seenClasses associations do:  [ :assoc |
			seenClasses at: assoc key put: ((assoc value) asOrderedCollection) . 
			
			 ].

	^ seenClasses
]

{ #category : #compute }
EGFInvocationModel >> computeMethodsSetFrom: graph [

	"from a invocationGraph based on the methods, outputs the class dependencies of these methods. 
	from A,B two classes and mA, mB two methods,
	if A:mA() invokes B:mB() then the their is a class dependencies from A to B.	
	"

	| recBlock seen methods |
	self
		deprecated: 'do not use anymore'
		on: '26 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.

	seen := Dictionary new.
	methods := Set new.


	recBlock := [ :root | 
	            root keysDo: [ :key | 
		            methods add:
			            (EGFMethodModel initFrom: key and: (root at: key)) ].


	            "explore next invocation"
	            root keysDo: [ :key | 
		            seen at: key ifAbsent: [ 
			            seen at: key put: true.
			            recBlock value: (root at: key) ] ] ].

	graph valuesDo: [ :dicInvo | 
		dicInvo keysDo: [ :key | recBlock value: (dicInvo at: key) ] ].

	^ methods
]

{ #category : #accessing }
EGFInvocationModel >> entryPoint [

	^ entryPoint
]

{ #category : #accessing }
EGFInvocationModel >> entryPoint: aFamixJavaMethod [

	entryPoint := aFamixJavaMethod
]

{ #category : #'as yet unclassified' }
EGFInvocationModel >> exportCSV [

	| export |
	export := String new.
	export := export , 'Class name, Method name, Complexity cyclo, LoC'
	          , String cr.
	flattenMethods associations do: [ :assoc | 
		| meth |
		meth := assoc key.

		export := export
		          ,
		          (meth parentType mooseName replaceAllRegex: ',' with: '_')
		          , ',' , (meth signature replaceAllRegex: ',' with: '_')
		          , ',' , meth cyclomaticComplexity printString , ','
		          , meth sourceText lines size printString , String cr ].
	^ export
]

{ #category : #'as yet unclassified' }
EGFInvocationModel >> exportComplexityCycloDiagramCSV [

	"export in CSV format a table of all methods with their respective cyclomatic Complexity. Sort the methods in respect of the invocation order."

	| export buildCsv recBlock seen safeGuard |
	export := 'method name, cycloComplexity' , String cr.
	safeGuard := 0.
	seen := Dictionary new.

	buildCsv := [ :method | 
	            export := export
	                      ,
	                      (method signature
		                       replaceAllRegex: ','
		                       with: '_') , ','
	                      , method cyclomaticComplexity printString
	                      , String cr ].


	recBlock := [ :mth | 
	            safeGuard > 100000 ifTrue: [ ^ export ] ifFalse: [safeGuard := safeGuard + 1].
	            seen at: mth ifAbsent: [ 
		            seen at: mth put: true.
		            (flattenMethods at: mth) do: [ :invoc | 
			            buildCsv value: invoc.
			            (flattenMethods at: invoc) do: [ :mthChild | 
				            recBlock value: mthChild ] ] ] ].

	buildCsv value: entryPoint.



	recBlock value: entryPoint.

	^ export
]

{ #category : #script }
EGFInvocationModel >> flattenInvocationGraph [

	| recBlock seen |
	self
		deprecated: 'Use #nothing instead'
		on: '27 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.
	seen := Dictionary new.

	seen at: self entryPoint ifAbsent: [ 
		seen
			at: self entryPoint
			put:
			(self invocationGraph at: self entryPoint) keys asOrderedCollection ].

	recBlock := [ :method | "explore next invocation"
	            method keysDo: [ :key | 
		            seen at: key ifAbsent: [ 
			            seen
				            at: key
				            put: (method at: key) keys asOrderedCollection.

			            recBlock value: (method at: key) ] ] ].

	self invocationGraph valuesDo: [ :dicInvo | 
		dicInvo keysDo: [ :key | 
			seen
				at: key
				ifAbsent: [ 
				seen at: key put: (dicInvo at: key) keys asOrderedCollection ].
			recBlock value: (dicInvo at: key) ] ].



	^ seen
]

{ #category : #accessing }
EGFInvocationModel >> flattenMethods [
	^ flattenMethods
]

{ #category : #intialization }
EGFInvocationModel >> initFrom: graph [

	self
		deprecated: 'Use #initFromInvocationGraph:andMethod: instead'
		on: '26 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.

	classGroup := Set new.
	classDependencies := Dictionary new.
	fmx2eGFMethods := Dictionary new.


	self root: graph keys first.
	self invocationGraph: graph.
	self convertToEGFModel: graph.
	self methodFlow: (self computeMethodsSetFrom: graph).
	self classGroup: (self computeClassGroupFrom: graph).

	self classDependencies: (self computeClassDependenciesFrom: graph)
]

{ #category : #intialization }
EGFInvocationModel >> initFromInvocationGraph: aGraph andMethod: methods [

	self
		deprecated: 'Use #initFromMethods:andAnEntryPoint: instead'
		on: '27 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.

	classGroup := Set new.
	classDependencies := Dictionary new.

	self entryPoint: aGraph keys first.
	self invocationGraph: aGraph.

	flattenMethods := methods.


	self classGroup: (self computeClassGroupV2From: methods).
	self classDependencies:
		(self computeClassDependenciesV2From: methods)
]

{ #category : #intialization }
EGFInvocationModel >> initFromMethods: methods andAnEntryPoint: aMethod [

	classGroup := Set new.
	classDependencies := Dictionary new.

	self entryPoint: aMethod.

	flattenMethods := methods.

	self classGroup: (self computeClassGroupV2From: methods).
	self classDependencies:
		(self computeClassDependenciesV2From: methods)
]

{ #category : #intialization }
EGFInvocationModel >> initialize [

	classGroup := Set new.
	classDependencies := Dictionary new.
	flattenMethods := Dictionary new.

]

{ #category : #accessing }
EGFInvocationModel >> invocationGraph [

	self
		deprecated: 'Use #nothing instead'
		on: '27 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.
	^ invocationGraph
]

{ #category : #setter }
EGFInvocationModel >> invocationGraph: aCollection [

	self
		deprecated: 'Use #nothing instead'
		on: '27 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.

	invocationGraph := aCollection
]

{ #category : #accessing }
EGFInvocationModel >> methods [

	^ self flattenMethods
]
