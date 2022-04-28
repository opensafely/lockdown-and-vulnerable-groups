from cohortextractor.codelistlib import codelist_from_csv

intdis_codes = codelist_from_csv(
    "codelists/opensafely-intellectual-disability.csv", system="ctv3", column="CTV3ID"
)

RCGPsafeguard_codes = codelist_from_csv(
    "codelists/user-S_Walter-rcgp-child-safeguarding.csv", system="snomed", column="code"
)

child_safeguard_codes = codelist_from_csv(
    "codelists/user-S_Walter-child-safeguarding.csv", system="snomed", column="code"
)

dva_codes = codelist_from_csv(
    "codelists/user-S_Walter-domestic-violence-abuse-complexity-factor.csv", system="snomed", column="code"
)

alc_misuse_codes = codelist_from_csv(
    "codelists/user-S_Walter-alcohol-misuse-complexity-factor.csv", system="snomed", column="code"
)