import pandas as pd
import os

input_directory = '/Users/michaelgreen/udemy/db-proj/data/us-dispos-all/xlsx'
# Define your output directory here
output_directory = '/Users/michaelgreen/udemy/db-proj/data/us-dispos-all/csv'

for filename in os.listdir(input_directory):
    if filename.endswith('.xlsx'):
        input_filepath = os.path.join(input_directory, filename)
        df = pd.read_excel(input_filepath)

        # Construct the output filepath and replace the extension
        output_filename = filename.replace('.xlsx', '.csv')
        output_filepath = os.path.join(output_directory, output_filename)

        df.to_csv(output_filepath, index=False)
