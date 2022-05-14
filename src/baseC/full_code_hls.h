

void matmultvec(DTYPE *res, int res_dim,
				DTYPE *mat, int mat_noRows, int mat_noColumns, 
				DTYPE *vec, int vec_dim);
				
void addvecs(DTYPE *res, int res_dim,
			 DTYPE *a, int a_dim,
			 DTYPE *b, int b_dim);

void subvecs(DTYPE *res, int res_dim,
			 DTYPE *a, int a_dim,
			 DTYPE *b, int b_dim);

void amultbtrans(DTYPE *res, int res_noRows, int res_noColumns,
				 DTYPE *a, int a_noRows, int a_noColumns, 
				 DTYPE *b, int b_noRows, int b_noColumns);

void amultb(DTYPE *res, int res_noRows, int res_noColumns,
			DTYPE *a, int a_noRows, int a_noColumns, 
			DTYPE *b, int b_noRows, int b_noColumns);

void addmats(DTYPE *res, int res_noRows, int res_noColumns,
			DTYPE *a, int a_noRows, int a_noColumns, 
			DTYPE *b, int b_noRows, int b_noColumns);

void submats(DTYPE *res, int res_noRows, int res_noColumns,
			DTYPE *a, int a_noRows, int a_noColumns, 
			DTYPE *b, int b_noRows, int b_noColumns);

void inversemat(DTYPE *res, int res_dimensions,
				DTYPE *a, int a_dimensions);

void covariancePredictor(DTYPE *Pk, DTYPE *F, DTYPE *Q);

void measurementResidual(DTYPE *zk, DTYPE *H, DTYPE *xk, DTYPE *yk);

void kalmangainCalculator(DTYPE *Pk, DTYPE *H, 	DTYPE *R, DTYPE *Kk);

void kalmanIterate(DTYPE *xk, DTYPE *uk, DTYPE *F, DTYPE *B, DTYPE *Pk, DTYPE *Q, DTYPE *yk, DTYPE *zk, DTYPE *H, DTYPE *Kk, DTYPE *R);

void kalmanIterate(DTYPE *xk, DTYPE *uk, DTYPE *F, DTYPE *B, DTYPE *Pk, DTYPE *Q, DTYPE *yk, DTYPE *zk, DTYPE *H, DTYPE *Kk, DTYPE *R);

