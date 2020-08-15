#!/bin/bash
SUBJ=$1
SUBJ_DIR=$2
surf=$3
label=$4
resultroot=$5
#pial_name=`basename $pial`
matlab=`which matlab`
Usage() {
    echo ""
    echo "Usage: $0 SUBJECT_ID SUBJECT_DIR SurferName(pial,inflate...) Label(BA1_exvivo,V1_exvivo...) resultroot"
    echo ""
    exit 1
}

[ "$1" = "" ] && Usage
mkdir -p $resultroot

for h in lh rh; do
	mris_convert $SUBJ_DIR/$SUBJ/surf/${h}.${surf} $resultroot/${h}.${surf}.asc
	asc=$resultroot/${h}.${surf}.asc
	srf=$resultroot/${h}.${surf}.srf
	obj=$resultroot/${h}.${surf}.obj
	mv $asc $srf
	src/srf2obj $srf > $obj

        mris_label2annot        --s $SUBJ \
                                --h $h \
                                --sd $SUBJ_DIR \
                                --ctab $SUBJ_DIR/$SUBJ/label/aparc.annot.ctab \
                                --a $label \
                                --l $SUBJ_DIR/$SUBJ/label/${h}.${label}.label \
				--l $SUBJ_DIR/$SUBJ/label/${h}.BA1_exvivo.label 
        annot_use=$resultroot/${h}.${label}.annot
	mv $SUBJ_DIR/$SUBJ/label/${h}.${label}.annot $annot_use
	$matlab -nodesktop -nosplash -r "annot2dpv $annot_use ${annot_use}.dpv;splitsrf $srf ${annot_use}.dpv $resultroot/${h}.pial.${label};exit;"
	for n_srf in `ls $resultroot/${h}.pial.${label}*.srf`; do
		n_obj=${n_srf%%srf}obj
		src/srf2obj $n_srf > $n_obj
	done
done


