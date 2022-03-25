from cohortextractor.codelistlib import codelist_from_csv

IntDis_codes = codelist_from_csv(
    "codelists/opensafely-intellectual-disability.csv", system="ctv3", column="CTV3ID"
)

RCGPsafeguard_codes = codelist_from_csv(
    "codelists/user-S_Walter-rcgp-child-safeguarding.csv", system="ctv3", column="code"
)