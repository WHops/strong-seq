import sys

# Get input arguments
invs_noSD_het_bed, invs_noSD_hom_bed, igv_run_script, igv_session, screenshot_dir = sys.argv[1:]

# List of bed files
bedfiles = [invs_noSD_het_bed, invs_noSD_hom_bed]

# Open the output bash script
with open(igv_run_script, 'w') as f:
    f.write('#!/bin/bash\n')  # starting line for a bash script
    for bed in bedfiles:
        # remove extension to use as directory name
        dir = bed.split('/')[-1].split('.')[0]
        # Write initial commands to the bash script
        f.write(f'new\n')
        f.write(f'genome hg38\n')  # Update genome version
        f.write(f'load {igv_session}\n')  # Update file to load
        f.write(f'snapshotDirectory {screenshot_dir}/{dir}\n')

        # Open the bed file and write the commands for each line
        with open(bed, 'r') as bedfile:
            for line in bedfile:
                chr, start, end = line.strip().split('\t')[:3]  # This assumes bed files with no header
                start, end = int(start), int(end)
                length = end - start
                mid = start + length // 2  # Calculate the midpoint of the region
                # Check if length is smaller than 50 kbp
                if length <= 500000:
                    # If so, set the start and end positions to create a window of exactly 1Mbp centered on the midpoint
                    start = mid - 500000
                    end = mid + 500000
                else:
                    # If not, expand by 50%
                    start = start - int(0.5 * length)
                    end = end + int(0.5 * length)
                f.write(f'goto {chr}:{start}-{end}\n')
                f.write(f'snapshot {chr}_{start}_{end}.png\n')