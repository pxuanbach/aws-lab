### Pull localstack image

```
docker pull localstack/localstack
```

### Download localstack-cli

https://github.com/localstack/localstack-cli

And move `.exe` to project location

### Create virtual env and install dependencies

```bash
py -m venv venv

# or
python -m venv venv
```

```bash
# window
./venv/Scripts/activate

# mac
source ./venv/bin/activate
```

```bash
pip install -r requirements.txt

# or (if you have "make" - GNU make)
make install
```

### Download Terraform


