# initially written by ChatGPT
import urllib.parse
import requests

# Step 1: Save SPARQL query as multiline string
sparql_query = """
SELECT DISTINCT STR(?sl) STR(?pl) STR(?ol)
FROM <http://www.snik.eu/ontology/bb>
{
 ?s ?p ?o.
 ?s rdfs:label ?sl.
 ?p rdfs:label ?pl.
 ?o rdfs:label ?ol.
 FILTER(LANGMATCHES(LANG(?sl),"en")&&LANGMATCHES(LANG(?pl),"en")&&LANGMATCHES(LANG(?ol),"en"))
}
"""

# Step 2: URL Encode the string
encoded_query = urllib.parse.quote(sparql_query)

# Step 3: Concatenate the URL and get the output
base_url = "https://www.snik.eu/sparql?default-graph-uri=http%3A%2F%2Fwww.snik.eu%2Fontology&format=text%2Ftab-separated-values&query="
full_url = base_url + encoded_query

response = requests.get(full_url)
output = response.text

# Step 4: Process the TSV output and print transformed lines to the console
lines = output.strip().split("\n")
for line in lines:
    parts = line.split("\t")
    if len(parts) == 3:
        subject, predicate, obj = [part.strip('"') for part in parts]
        predicate = predicate.replace('entity type component', 'has the entity type component')
        predicate = predicate.replace('function component', 'has the function component')
        predicate = predicate.replace('role component', 'includes ')
        transformed_line = f"{subject.strip()} {predicate.strip()} {obj.strip()}."
        print(transformed_line)
