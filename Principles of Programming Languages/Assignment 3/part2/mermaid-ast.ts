/*
=============================================================================

<graph> ::= <header> <graphContent> // Graph(dir: Dir, content: GraphContent)
<header> ::= graph (TD|LR)<newline> // Direction can be TD or LR
<graphContent> ::= <atomicGraph> | <compoundGraph>
<atomicGraph> ::= <nodeDecl>
<compoundGraph> ::= <edge>+
<edge> ::= <node> --><edgeLabel>? <node><newline> // <edgeLabel> is optional
// Edge(from: Node, to: Node, label?: string)
<node> ::= <nodeDecl> | <nodeRef>
<nodeDecl> ::= <identifier>["<string>"] // NodeDecl(id: string, label: string)
<nodeRef> ::= <identifier> // NodeRef(id: string)
<edgeLabel> ::= |<identifier>| // string

=============================================================================
*/
export type GraphContent =  AtomicGraph | CompoundGraph;
export type Header = TD | LR;
export type Node = NodeDecl | NodeRef;

export interface Graph {tag: "Graph"; header: Header; graphContent: GraphContent; }
export interface AtomicGraph {tag: "AtomicGraph"; nodeDecl: NodeDecl; }
export interface CompoundGraph {tag: "CompoundGraph"; edges: Edge[]; }
export interface Edge {tag: "Edge"; from: Node; to: Node; label?: EdgeLabel; }
export interface NodeDecl {tag: "NodeDecl"; id: string; label: string; }
export interface NodeRef {tag: "NodeRef"; id: string; }
export interface EdgeLabel {tag: "EdgeLabel"; label: string; }
export interface TD {tag: "TD"; }
export interface LR {tag: "LR"; }

// Type value constructors for disjoint types
export const makeGraph = (header: Header, graphContent: GraphContent): Graph => ({tag: "Graph", header: header, graphContent: graphContent});
export const makeAtomicGraph = (nodeDecl: NodeDecl): AtomicGraph => ({tag: "AtomicGraph", nodeDecl: nodeDecl});
export const makeCompoundGraph = (edges: Edge[]): CompoundGraph => ({tag: "CompoundGraph", edges: edges});
export const makeEdge = (from: Node, to: Node, label?: EdgeLabel): Edge => ({tag: "Edge", from: from, to: to, label: label});
export const makeNodeDecl = (id: string, label: string): NodeDecl => ({tag: "NodeDecl", id: id, label: label});
export const makeNodeRef = (id: string): NodeRef => ({tag: "NodeRef", id: id});
export const makeEdgeLabel = (label: string): EdgeLabel => ({tag: "EdgeLabel", label: label});
export const makeTD = (): TD => ({tag: "TD"});
export const makeLR = (): LR => ({tag: "LR"});

// Type predicates for disjoint types
export const isGraph = (x: any): x is Graph => x.tag === "Graph";
export const isAtomicGraph = (x: any): x is AtomicGraph => x.tag === "AtomicGraph";
export const isCompoundGraph = (x: any): x is CompoundGraph => x.tag === "CompoundGraph";
export const isEdge = (x: any): x is Edge => x.tag === "Edge";
export const isNodeDecl = (x: any): x is NodeDecl => x.tag === "NodeDecl";
export const isNodeRef = (x: any): x is NodeRef => x.tag === "NodeRef";
export const isEdgeLabel = (x: any): x is EdgeLabel => x.tag === "EdgeLabel";
export const isTD = (x: any): x is TD => x.tag === "TD";
export const isLR = (x: any): x is LR => x.tag === "LR";

export const isGraphContent = (x: any): x is GraphContent => isAtomicGraph(x) || isCompoundGraph(x);
export const isHeader = (x: any): x is Header => isTD(x) || isLR(x);
export const isNode = (x: any): x is Node => isNodeDecl(x) || isNodeRef(x);


