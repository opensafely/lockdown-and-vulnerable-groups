from cohortextractor.codelistlib import codelist_from_csv

IntDis_codes = codelist_from_csv(
    "codelists/opensafely-intellectual-disability.csv", system="ctv3", column="CTV3ID"
)

RCGPsafeguard_codes = codelist_from_csv(
    "codelists/user-S_Walter-rcgp-child-safeguarding.csv", system="ctv3", column="code"
)

depression = codelist_from_csv(
    "codelists/user-hjforbes-depression-symptoms-and-diagnoses-499814eb", system="snomed", column="code"
)

anxiety = codelist_from_csv(
    "codelists/user-hjforbes-anxiety-symptoms-and-diagnoses-3088a1b6", system="snomed", column="code"
)

ocd = codelist_from_csv(
    "codelists/user-hjforbes-obsessive-compulsive-disorder-ocd-17792e81", system="snomed", column="code"
)

ptsd = codelist_from_csv(
    "codelists/user-hjforbes-post-traumatic-stress-disorder-7e69bb4b", system="snomed", column="code"
)

eating_disord = codelist_from_csv(
    "codelists/user-hjforbes-diagnoses-eating-disorder-62a78820", system="snomed", column="code"
)

severe_mental = codelist_from_csv(
    "codelists/user-hjforbes-severe-mental-illness-2dd5e1c0", system="snomed", column="code"
)

selfharm10 = codelist_from_csv(
    "codelists/user-hjforbes-intentional-self-harm-aged10-years-18951e5c", system="snomed", column="code"
)

selfharm15 = codelist_from_csv(
    "codelists/user-hjforbes-undetermined-intent-self-harm-aged15-years/4d66c4bc", system="snomed", column="code"
)