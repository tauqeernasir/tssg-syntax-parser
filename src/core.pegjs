
Grammar
    = Expression*

Expression
    = SchemasBlockExpression

SchemasBlockExpression
    = "Schemas" _ "{" _ "}"

_ "whitespace"
  = ("\t"
  / "\v"
  / "\f"
  / " "
  / "\u00A0"
  / "\uFEFF")*