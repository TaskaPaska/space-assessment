import pandas as pd
import json
from datetime import datetime, timedelta


# Function to parse contracts to handle the initial string format
def parse_contracts(contracts):
    # Handling cases when there's no data
    if pd.isna(contracts):
        return []

    # Raw string format turns into json
    parsed = json.loads(contracts)

    # jsons are usually packed in a list
    if isinstance(parsed, list):
        return parsed

    # Handling the case when there's a single instance of a json, when it's not in a list
    elif isinstance(parsed, dict):
        return [parsed]


# Function to parse application_date, since sometimes it includes microseconds, sometimes it does not
def parse_application_date(application_date):
    try:
        return datetime.strptime(application_date, "%Y-%m-%d %H:%M:%S.%f%z").replace(tzinfo=None)
    except ValueError:
        return datetime.strptime(application_date, "%Y-%m-%d %H:%M:%S%z").replace(tzinfo=None)


# Function to count claims within the last 180 days relative to application_date
def count_claims(application_date, contracts):
    # The instructions doc did not specify whether to use the current date or the application_date
    # in relation to "last 180 days".
    # I chose application_date since I think it makes more sense for financial/analytical purposes (while checking
    # client's history), but alternatively end_date = datetime.now() could work.
    application_date = parse_application_date(application_date)
    end_date = application_date
    start_date = end_date - timedelta(days=180)
    count = None

    # Iterating trough contracts for each record
    if contracts:
        # Initially, count of claims for each record should be set to 0
        count = 0
        for contract in contracts:
            claim_date_raw = contract.get('claim_date')
            # Not considering cases where claim date is null
            if claim_date_raw:
                claim_date = datetime.strptime(claim_date_raw, "%d.%m.%Y")

                # If the claim was made through last 180 days, increase the count by 1
                if start_date <= claim_date <= application_date:
                    count += 1

    # In case no claims (including claims made earlier than 180 days), -3 is put as the value of the feature
    # (considering that according to the instructions, -3 replaces a missing value, not 0)
    if count is None:
        return -3
    return count


# Function to count sum of exposure of loans, without TBC loans
def sum_loans(contracts):
    disbursed_loan_count = None
    exposure_sum = None

    # Iterating trough contracts for each record
    if contracts:
        disbursed_loan_count = 0
        exposure_sum = 0
        for contract in contracts:
            bank = contract.get('bank')
            loan_summa = contract.get('loan_summa')
            contract_date = contract.get('contract_date')

            # If the bank field is valid and contract_date is not null, then add loan_summa to the total sum.
            # Counting the amount of loans separately, a loan counts if contract_date is present.
            if contract_date:
                disbursed_loan_count += 1
                if bank not in unwanted_banks:
                    loan_summa = loan_summa if loan_summa else 0
                    exposure_sum += loan_summa

    # In case no claims, return -3
    if exposure_sum is None and disbursed_loan_count is None:
        return -3
    # In case no loans, return -1
    elif disbursed_loan_count == 0:
        return -1

    return exposure_sum


# Function to count the number of days since the last loan
def days_since_last_loan(application_date, contracts):
    application_date = parse_application_date(application_date)
    # Last loan date is set to None for every record by default
    last_loan_date = None

    # Iterating trough contracts for each record
    for contract in contracts:
        summa = contract.get('summa')
        contract_date_raw = contract.get('contract_date')

        # Considering loans where summa is not null and contract_date is not null
        if summa is not None and contract_date_raw:
            contract_date = datetime.strptime(contract_date_raw, "%d.%m.%Y")
            # If the currently stored date is later than the one on the current iteration,
            # store that as the new last_loan_date
            if last_loan_date is None or contract_date > last_loan_date:
                last_loan_date = contract_date

    if last_loan_date:
        # Calculating the difference in days between application_date and last_loan_date
        days_diff = (application_date - last_loan_date).days
        return days_diff
    elif contracts:
        # There are claims, but none with a valid loan (summa not null)
        return -1
    else:
        # No claims at all
        return -3

# Function to count average amount of exposure per record
def avg_loan_amount(contracts):
    '''
    Source: contracts
    Key fields: loan_summa, contract_date
    Special notes: Only include contracts where loan_summa is not null.
    If missing value: In case no loans at all, value is -3.
    '''
    # Filter out contracts where loan_summa is null or empty
    valid_loans = [contract['loan_summa'] for contract in contracts if contract.get('loan_summa')]

    # Compute the average loan amount
    if valid_loans:
        avg_amount = sum(valid_loans) / len(valid_loans)
    else:
        avg_amount = -3

    return round(avg_amount, 2)


df = pd.read_csv('data.csv')

# Parsing the contracts column
df['contracts'] = df['contracts'].apply(parse_contracts)

# Calculating each feature
df['tot_claim_cnt_l180d'] = df.apply(lambda row: count_claims(row['application_date'], row['contracts']), axis=1)

unwanted_banks = ['LIZ', 'LOM', 'MKO', 'SUG', None]
df['disb_bank_loan_wo_tbc'] = df['contracts'].apply(sum_loans)

df['day_sinlastloan'] = df.apply(lambda row: days_since_last_loan(row['application_date'], row['contracts']), axis=1)

df['avg_loan_amount'] = df['contracts'].apply(avg_loan_amount)

# Exporting to a CSV file
df.to_csv('contract_features.csv', index=False)

# print(df.drop(columns=['contracts']).to_string())
