:- dynamic prolog_files/2, prolog_files/3, md/2, possible/1.

:- multifile genlsDirectlyList/2.
:- discontiguous are/2, isa/2.
:- dynamic holds/2.

:- use_module(library(make)).
:- use_module(library(julian)).

:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/util/util.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/dates/frdcsa/sys/flp/autoload/dates.pl').

spse2FormalogFlag(not(debug)).

viewIf(Item) :-
 	(   spse2FormalogFlag(debug) -> 
	    view(Item) ;
	    true).

testSpse2Formalog :-
	true.

list_all_contexts(Context) :-
	shell_command_to_string('spse2 -l',Result),
	split_string(Result,'\n','',StringContexts),
	member(StringContext,StringContexts),
	atom_string(Context,StringContext),
	Context \= '',
	view([context,Context]).

load_all_contexts :-
	findall(Context,list_all_contexts(Context),Contexts),
	spse2_formalog_load_contexts('SPSE2-Formalog-Agent1','SPSE2-Formalog-Yaswi1',Contexts).

spse2_formalog_assert_list(_Context, [ ] ).
spse2_formalog_assert_list(Context, [ X | Y ] ):- write('Asserting into <'),write(Context),write('>: '),write_term(X,[quoted(true)]),assert(holds(Context,X)),nl,spse2_formalog_assert_list(Context,Y).

spse2_formalog_load_database(AgentName,FormalogName,Context) :-
	kquery(AgentName,FormalogName,nil,Bindings),
	spse2_formalog_assert_list(Context,Bindings).

spse2_formalog_load_contexts(AgentName,FormalogName,Contexts) :-
	getOption(loadContexts,LoadContexts),
	(   LoadContexts == true ->
	    (	
		getVar(AgentName,FormalogName,'context',Var),
		kbs2Data(Var,CurrentContext),
		forall(member(Context,Contexts),
		       (   
			   setContext(AgentName,FormalogName,Context),
			   nl,write('LOADING CONTEXT: '),write(Context),nl,
			   spse2_formalog_load_database(AgentName,FormalogName,Context)
		       )),
		setContext(AgentName,FormalogName,CurrentContext)
	    ) ;
	    true).

%% :- load_all_contexts.


getAllPredicates(Predicates) :-
	setof(P,X^Y^A^(holds(X,Y),Y=..[P|A]),Predicates).


getPrefixPlusContext(Prefix,Context,PrefixPlusContext) :-
	atomic_list_concat([Prefix,'+',Context],'',PrefixPlusContext).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

asserter('entry-fn'(PrefixPlusContext,ID),Asserter) :-
	holds(Context,asserter('entry-fn'(Prefix,ID),Asserter)),
	getPrefixPlusContext(Prefix,Context,PrefixPlusContext).

'end-date'('entry-fn'(PrefixPlusContext,ID),Date) :-
	holds(Context,'end-date'('entry-fn'(Prefix,ID),Date)),
	getPrefixPlusContext(Prefix,Context,PrefixPlusContext).	      

goal('entry-fn'(PrefixPlusContext,ID)) :-
	holds(Context,goal('entry-fn'(Prefix,ID))),
	getPrefixPlusContext(Prefix,Context,PrefixPlusContext).

'has-NL'('entry-fn'(PrefixPlusContext,ID),NL) :-
	holds(Context,'has-NL'('entry-fn'(Prefix,ID),NL)),
	getPrefixPlusContext(Prefix,Context,PrefixPlusContext).

'has-source'('entry-fn'(PrefixPlusContext,ID),Source) :-
	holds(Context,'has-source'('entry-fn'(Prefix,ID),Source)),
	getPrefixPlusContext(Prefix,Context,PrefixPlusContext).

'start-date'('entry-fn'(PrefixPlusContext,ID),Date) :-
	holds(Context,'start-date'('entry-fn'(Prefix,ID),Date)),
	getPrefixPlusContext(Prefix,Context,PrefixPlusContext).	      

depends('entry-fn'(PrefixPlusContext1,ID1),'entry-fn'(PrefixPlusContext2,ID2)) :-
	holds(Context,'depends'('entry-fn'(Prefix1,ID1),'entry-fn'(Prefix2,ID2))),
	getPrefixPlusContext(Prefix1,Context,PrefixPlusContext1),
	getPrefixPlusContext(Prefix2,Context,PrefixPlusContext2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% [
%%  asserter,
%%  cancelled,
%%  completed,
%%  condition,
%%  costs,
%%  deleted,
%%  depends,
%%  earns,
%%  eases,
%%  'end-date',
%%  'ethicality-concern',
%%  'event-duration',
%%  'frdcsa-context-type',
%%  goal,
%%  habitual,
%%  'hard-time-constraints',
%%  'has-NL',
%%  'has-formalization',
%%  'has-parent',
%%  'has-parent-file',
%%  'has-source',
%%  'interested-in',
%%  involves,
%%  not,
%%  obsoleted,
%%  'prefer same',
%%  provides,
%%  rejected,
%%  ridiculous,
%%  severity,
%%  shoppinglist,
%%  showstopper,
%%  skipped,
%%  'start-date'
%% ]

goalAndNL(Entry,NL) :-
	goal(Entry),
	'has-NL'(Entry,NL).

:- log_message('DONE LOADING SPSE2-FORMALOG.').
formalogModuleLoaded(spse2Formalog).
