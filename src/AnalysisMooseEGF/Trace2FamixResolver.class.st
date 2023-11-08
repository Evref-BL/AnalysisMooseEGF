Class {
	#name : #Trace2FamixResolver,
	#superclass : #Object,
	#category : #AnalysisMooseEGF
}

{ #category : #'as yet unclassified' }
Trace2FamixResolver >> refineCandidates: candidates withSignature: methodSignature [

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
		            | check mooseSignature parmNames orderedMooseParams|
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
