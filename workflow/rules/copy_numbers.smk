def collect_mosdepth_input(wildcards):
    print(samples)
    bam_path = samples.query(f"sample_name == {wildcards.sample}")["bam"]
    print(bam_path)
    bai_path = bam_path + ".bai"
    return {
        "bam" : bam_path,
        "bai" : bai_path,
    }

rule mosdepth_by_window:
    input:
        unpack(collect_mosdepth_input)
    output:
        "results/mosdepth/{sample}.mosdepth.global.dist.txt",
        "results/mosdepth/{sample}.mosdepth.region.dist.txt",
        "results/mosdepth/{sample}.regions.bed.gz",
        summary="results/mosdepth/{sample}.mosdepth.summary.txt",  # this named output is required for prefix parsing
    log:
        "logs/mosdepth/{sample}.log",
    params:
        by="5000",  # optional, window size,  specifies --by for mosdepth.region.dist.txt and regions.bed.gz
    # additional decompression threads through `--threads`
    threads: 4  # This value - 1 will be sent to `--threads`
    wrapper:
        "v7.0.0/bio/mosdepth"


rule maftools_segmentation_with_background_alias:
    input:
        mosdepth_main=expand(
            "results/mosdepth/{sample}.regions.bed.gz",
            sample=lookup(within=samples, query="sample_name == {sample}"),
        ),
        mosdepth_background=expand(
            "results/mosdepth/{sample}.regions.bed.gz",
            sample=lookup(within=samples, query="sample_name == {sample}"),
        ),
    output:
        segments="results/maftools/{group}.{alias}.cbs.seg",
        plot="results/maftools/{group}.{alias}.cbs.pdf",
    log:
        "logs/maftools/{group}.{alias}.cbs.log",
    conda:
        "../envs/maftools.yaml"
    script:
        "../scripts/maftools_mosdepth_segmentation.R"
    


rule maftools_segmentation_single_sample:
    input:
        mosdepth="results/mosdepth/{sample}.regions.bed.gz",
    output:
        segments="results/maftools/{sample}.cbs.seg",
        plot="results/maftools/{sample}.cbs.pdf",
    log:
        "logs/maftools/{sample}.cbs.log",
    conda:
        "../envs/maftools.yaml"
    script:
        "../scripts/maftools_mosdepth_segmentation.R"
    