"
Ready to use Playground code : 

eGF := EGFEvolAnalysis new.

ucName := 'UcTiersComptableImpl'.
mthName := 'fournirListeTiersComptablesIHM'.

eGFModel := eGF createEGFModelFromUCName: ucName andMethodName: mthName.

""use RSeGFService to access difference Roassal representation, e.g. buildClassDependenciesCanvas and buildInvocationGraphCanvas""
(RSeGFService new eGFInvocationModel: eGFModel; buildClassDependenciesCanvas  ) open.

"
Class {
	#name : #EGFEvolAnalysis,
	#superclass : #Object,
	#instVars : [
		'invocationGraphCache',
		'methodInvokedCache'
	],
	#category : #AnalysisMooseEGF
}

{ #category : #script }
EGFEvolAnalysis >> OldComputeInvocationGraphOfUc: ucName andMethods: mthName withCache: withCache [

	"ucName := 'UcTiersComptableImpl'.
	mthName := 'fournirListeTiersComptablesIHM'."

	<script>
	| evol ucs seen res block meth |
	self
		deprecated:
		'Use #computeInvocationGraphOfUc:andMethods:withCache: instead'
		on: '26 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.
	evol := MooseModel root at: 1.
	ucs := evol allClasses select: [ :c | 
		       (c name beginsWith: 'uc' caseSensitive: false) and: [ 
			       c name endsWith: 'impl' caseSensitive: false ] ].
	seen := Dictionary new.
	res := Dictionary new.
	block := [ :m :outgoing | 
	         m queryAllOutgoing select: #isInvocation thenDo: [ :i | 
		         | method |
		         method := i candidates anyOne.
		         method isStub ifFalse: [ 
			         seen
				         at: method
				         ifPresent: [ :out | outgoing at: method put: out ]
				         ifAbsent: [ 
					         | recurOut |
					         recurOut := Dictionary new.
					         outgoing at: method put: recurOut.
					         seen at: method put: recurOut.
					         block value: method value: recurOut ] ] ].
	         outgoing ].
	meth := (ucs detect: [ :uc | uc name = ucName ]) methods detect: [ :m | 
		        m name = mthName ].
	res at: meth put: (block value: meth value: Dictionary new).

	withCache ifTrue: [ 
		invocationGraphCache at: ucName , mthName put: res ].

	^ res
]

{ #category : #'as yet unclassified' }
EGFEvolAnalysis >> allInvockedMethodsOf: aMethod [
	


	^ (aMethod queryAllOutgoing select: #isInvocation)
		  asOrderedCollection select: [ :invocation | 
		  | methodInvoc |
		  "select any candidate method that could be the receiver candidat of m"
		  methodInvoc := invocation candidates anyOne.

		  "if the invoked method is not a stub"
		  methodInvoc isStub = false ]
]

{ #category : #script }
EGFEvolAnalysis >> analysis [

	<script>
	| evol ucs seen res block meth |
	self
		deprecated: 'Use #nothing instead'
		on: '27 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.
	evol := MooseModel root at: 1.
	ucs := evol allClasses select: [ :c | 
		       (c name beginsWith: 'uc' caseSensitive: false) and: [ 
			       c name endsWith: 'impl' caseSensitive: false ] ].
	seen := Dictionary new.
	res := Dictionary new.
	block := [ :m :outgoing | 
	         m queryAllOutgoing select: #isInvocation thenDo: [ :i | 
		         | method |
		         method := i candidates anyOne.
		         method isStub ifFalse: [ 
			         seen
				         at: method
				         ifPresent: [ :out | outgoing at: method put: out ]
				         ifAbsent: [ 
					         | recurOut |
					         recurOut := Dictionary new.
					         outgoing at: method put: recurOut.
					         seen at: method put: recurOut.
					         block value: method value: recurOut ] ] ].
	         outgoing ].
	meth := (ucs detect: [ :uc | uc name = 'UcTiersComptableImpl' ])
		        methods detect: [ :m | 
		        m name = 'fournirListeTiersComptablesIHM' ].
	res at: meth put: (block value: meth value: Dictionary new).
	^ res
]

{ #category : #script }
EGFEvolAnalysis >> computeInvocationGraphOfUc: ucName andMethodName: mthName withCache: withCache [

	"ucName := 'UcTiersComptableImpl'.
	mthName := 'fournirListeTiersComptablesIHM'."

	<script>
	| evol ucs visitedMethods res block meth |
	self
		deprecated:
		'Use #newComputeInvocationGraphOfUc:andMethodName:withCache: instead'
		on: '27 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.
	evol := MooseModel root at: 1.
	"get all class that is an UCs in eGF"
	ucs := evol allClasses select: [ :c | 
		       (c name beginsWith: 'uc' caseSensitive: false) and: [ 
			       c name endsWith: 'impl' caseSensitive: false ] ].

	visitedMethods := Dictionary new.
	res := Dictionary new.

	"recursive visiting block"
	block := [ :method :outgoing | "look throught all outgoing entities of m and search the invocation m makes"
	         (method queryAllOutgoing select: #isInvocation)
		         asOrderedCollection do: [ :invocation | 
		         | methodInvoc |
		         "select any candidate method that could be the receiver candidat of m"
		         methodInvoc := invocation candidates anyOne.

		         "if the invoked method is not a stub"
		         methodInvoc isStub ifFalse: [ "check if this methodInvoc not stub as already been seen"
			         visitedMethods
				         at: methodInvoc
				         ifPresent: [ :out | outgoing at: methodInvoc put: out ]
				         ifAbsent: [ 
					         | recurOut |
					         recurOut := Dictionary new.
					         outgoing at: methodInvoc put: recurOut.
					         visitedMethods at: methodInvoc put: recurOut.
					         block value: methodInvoc value: recurOut ] ] ].
	         outgoing ].

	"get methods of the UC named from parameters that are named named also from parameters"
	meth := (ucs detect: [ :uc | uc name = ucName ]) methods detect: [ :m | 
		        m name = mthName ].


	"recursivly explore the methods invocations graph"
	res at: meth put: (block value: meth value: Dictionary new).



	withCache ifTrue: [ 
		invocationGraphCache at: ucName , mthName put: res.

		methodInvokedCache
			at: ucName , mthName
			put: (self flattenInvocationGraph: res) ].

	^ self
]

{ #category : #'as yet unclassified' }
EGFEvolAnalysis >> createEGFModelFromUCName: UCname andMethodName: methodName [

	"create a instance of eGFModelInvocation"

	| model invocGraph methodSet |
	self
		deprecated:
		'Use #newCreateEGFModelFromUCName:andMethodName: instead'
		on: '27 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.
	model := EGFInvocationModel new.

	invocationGraphCache at: UCname , methodName ifAbsent: [ 
		self
			computeInvocationGraphOfUc: UCname
			andMethodName: methodName
			withCache: true ].

	invocGraph := invocationGraphCache at: UCname , methodName.
	methodSet := methodInvokedCache at: UCname , methodName.

	model initFromInvocationGraph: invocGraph andMethod: methodSet.
	^ model
]

{ #category : #'as yet unclassified' }
EGFEvolAnalysis >> exportCSV: methods [

	| export |
	export := String new.
	export := export , 'Class name, Method name, Complexity cyclo, LoC'
	          , String cr.
	methods associations do: [ :assoc | 
		| meth |
		meth := assoc key.

		export := export , (meth parentType mooseName replaceAllRegex: ',' with: '_') , ','
		          , (meth signature replaceAllRegex: ',' with: '_') , ','
		          , meth cyclomaticComplexity printString , ','
		          , meth sourceText lines size printString , String cr ].
	^ export
]

{ #category : #'as yet unclassified' }
EGFEvolAnalysis >> flattenInvocationGraph: invocationGraph [

	"retrieve the invocation methods graph as a flatten dictionary"

	| recBlock seen entryPoint |
	self
		deprecated: 'Use #retrieveInvocationGraphFromMethod: instead'
		on: '27 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.
	seen := Dictionary new.

	entryPoint := invocationGraph keys first.

	seen at: entryPoint ifAbsent: [ 
		seen
			at: entryPoint
			put: (invocationGraph at: entryPoint) keys asOrderedCollection ].

	recBlock := [ :method | "explore next invocation"
	            method keysDo: [ :key | 
		            seen at: key ifAbsent: [ 
			            seen
				            at: key
				            put: (method at: key) keys asOrderedCollection.

			            recBlock value: (method at: key) ] ] ].

	invocationGraph valuesDo: [ :dicInvo | 
		dicInvo keysDo: [ :key | 
			seen
				at: key
				ifAbsent: [ 
				seen at: key put: (dicInvo at: key) keys asOrderedCollection ].
			recBlock value: (dicInvo at: key) ] ].



	"	seen associations do: [ :assoc | 
		self haltIf: [ assoc value size > 3]. 
		assoc value sort: [ :meth1 :meth2 | 
			meth1 sourceAnchor endPos  < meth2 sourceAnchor endPos  ] ]."

	^ seen
]

{ #category : #initialization }
EGFEvolAnalysis >> initialize [

	invocationGraphCache := Dictionary new.
	methodInvokedCache := Dictionary new.
]

{ #category : #script }
EGFEvolAnalysis >> invocationGraphOfUc: ucName andMethodName: mthName [

	self
		deprecated: 'Use #nothing instead'
		on: '27 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.

	invocationGraphCache
		at: ucName , mthName
		ifPresent: [ invocationGraphCache at: ucName , mthName ]
		ifAbsent: [ 
			self
				computeInvocationGraphOfUc: ucName
				andMethodName: mthName
				withCache: true ]
]

{ #category : #script }
EGFEvolAnalysis >> invocationGraphOfUcTiersComptableImplWithFournirListeTiersComptablesIHM [

	<script>
	| evol ucs seen res block meth |
	self
		deprecated: 'Use #nothing instead'
		on: '27 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.
	evol := MooseModel root at: 1.
	ucs := evol allClasses select: [ :c | 
		       (c name beginsWith: 'uc' caseSensitive: false) and: [ 
			       c name endsWith: 'impl' caseSensitive: false ] ].
	seen := Dictionary new.
	res := Dictionary new.

	"block de recursion pour parcourir le model"
	block := [ :m :outgoing | 
	         m queryAllOutgoing select: #isInvocation thenDo: [ :i | 
		         | method |
		         method := i candidates anyOne.
		         method isStub ifFalse: [ 
			         seen
				         at: method
				         ifPresent: [ :out | outgoing at: method put: out ]
				         ifAbsent: [ 
					         | recurOut |
					         recurOut := Dictionary new.
					         outgoing at: method put: recurOut.
					         seen at: method put: recurOut.
					         block value: method value: recurOut ] ] ].
	         outgoing ].


	meth := (ucs detect: [ :uc | uc name = 'UcTiersComptableImpl' ])
		        methods detect: [ :m | 
		        m name = 'fournirListeTiersComptablesIHM' ].
	res at: meth put: (block value: meth value: Dictionary new).
	^ res
]

{ #category : #script }
EGFEvolAnalysis >> newComputeInvocationGraphOfUc: ucName andMethodName: mthName withCache: withCache [

	"ucName := 'UcTiersComptableImpl'.
	mthName := 'fournirListeTiersComptablesIHM'."

	<script>
	| evol ucs  res meth |
	evol := MooseModel root at: 1.
	"get all class that is an UCs in eGF"
	ucs := evol allClasses select: [ :c | 
		       (c name beginsWith: 'uc' caseSensitive: false) and: [ 
			       c name endsWith: 'impl' caseSensitive: false ] ].

	res := Dictionary new.


	"get methods of the UC named from parameters that are named named also from parameters"
	meth := (ucs detect: [ :uc | uc name = ucName ]) methods detect: [ :m | 
		        m name = mthName ].

	res := self retrieveInvocationGraphFromMethod: meth.

	withCache ifTrue: [ 
		methodInvokedCache at: ucName , mthName put: meth -> res ].

	^ self
]

{ #category : #'as yet unclassified' }
EGFEvolAnalysis >> newCreateEGFModelFromUCName: UCname andMethodName: methodName [

	"create a instance of eGFModelInvocation"

	| model methodSet entryPoint|
	model := EGFInvocationModel new.

	methodInvokedCache at: UCname , methodName ifAbsent: [ 
		self
			newComputeInvocationGraphOfUc: UCname
			andMethodName: methodName
			withCache: true ].

	methodSet := (methodInvokedCache at: UCname , methodName) value.
	entryPoint := (methodInvokedCache at: UCname , methodName) key.

	model initFromMethods: methodSet andAnEntryPoint: entryPoint.
	^ model
]

{ #category : #'as yet unclassified' }
EGFEvolAnalysis >> orderByPositionAMethodInvocations: aMethod [

	| invocations positions |
	

	"self allInvockedMethodsOf: aMethod "
	
	positions := (self allInvockedMethodsOf: aMethod )
		             collect: [ :invoc | 
			             | mth endpos |
			             mth := invoc candidates anyOne.
			             endpos := invoc sourceAnchor endPos.
			             mth -> endpos ].
	invocations := Dictionary new.
	positions do: [ :assoc | 
		invocations
			at: assoc key
			ifPresent: [ :oldVal | 
				oldVal > assoc value ifTrue: [ 
					invocations at: assoc key put: assoc value ] ]
			ifAbsent: [ invocations at: assoc key put: assoc value ] ].

	^ (invocations associations sort: [ :a1 :a2 | a1 value < a2 value ]) 
		  collect: [ :e | e key ]
]

{ #category : #initialization }
EGFEvolAnalysis >> resetCache [

	invocationGraphCache := Dictionary new
]

{ #category : #'instance creation' }
EGFEvolAnalysis >> retrieveInvocationGraphFromMethod: aMethod [

	"retrieve the invocation methods graph as a flatten dictionary"

	| recBlock seen |
	seen := Dictionary new.


	recBlock := [ :method | "explore next invocation"
	            seen at: method ifAbsent: [ 
		            seen
			            at: method
			            put: (self orderByPositionAMethodInvocations: method).
		            (seen at: method) do: [ :child | recBlock value: child ] ] ].



	recBlock value: aMethod.


	^ seen
]
