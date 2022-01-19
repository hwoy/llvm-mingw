finish()
{
	sh utils/INSTALL.sh ${X_BUILDDIR} $(dirname ${NEW_DISTRO_ROOT})

	cd ${DIR}

	mv ${X_BUILDDIR}/*.7z $1

}

buildpkg()
{
	cd $1
	sh $2
	cd ..
	finish $3
}
